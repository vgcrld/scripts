#!/usr/bin/env ruby

require 'galileo/application/api'
require 'optimist'

TRANSLATION_MAP = {
    'cc83aceacf83e6119c673cfdfe02e7c2' => '4211b3db-cceb-fdd0-7b90-2315d61cf298',
    'f3e50b7ec73911dbb6b826a30cf91b04' => '0029f88e-57ce-5861-0299-a12ba31570f9',
    '0000000048fa11dd94b408630a140021' => '87993a2e-5816-7f68-81d3-d5f1b0e652a9',
    'c4c068e67ece11e19d42000315000000' => 'dc26c19a-f1ea-eecf-8e13-1c2d79f2b43c',
    '5ab25322eb0ce811a58e7cd30aea05f0' => '870b246b-4a3d-2011-8454-df2cb2b1feec',
    'a46df78a0f3eea11acb33868dd1ca649' => '4b64733d-78e1-545a-f5aa-e119043bbf96',
    'f2d2bef01af811df8bd9009a01040000' => '63cf2b7d-bb41-40ca-f635-73d3c075c20e',
    '3ea0fe138b9be6119d78e0071bf7e520' => :expired,
    '488ae82b8b9be611a1a4e0071bf70b64' => '387b7540-b819-542b-b19d-f9ab977fdee4',
    'a64fbe739e9de511a5f80025b50a006d' => '3d7ef905-061b-1af7-bf14-2d24d40e9883',
    '60e527c0992de611bc580025b50401ff' => 'c39710bb-c78e-1e78-7f81-61f22e32f19f',
    'b64c1f141101e811959b0025b5a4005d' => '9efc59d3-1693-75aa-4d54-c544ff21fbef',
    '12e8e2453183ea11892e3868dd205f50' => '6236d25a-11e7-bfde-2f90-e51f0f88fd5d',
    'd60b21da185e11e682260894ef035c20' => :expired
}

def clickhouse(translation)
    File.open('clickhouse.sql', 'w') do |f|
        translation.each do |customer,map|
            f.puts %Q{select now(),'#{customer}';}
            map.each do |to_from|
                curr, newn = to_from
                if newn == :expired
                    f.puts %Q[alter table data__#{customer}.__items update visible=0, reporting=0, loading=0 where key = 'tsm_#{curr}';]
                else
                    f.puts %Q[alter table data__#{customer}.__items update key=replaceOne(key,'tsm_#{curr}','tsm_#{newn}') where key like 'tsm_#{curr}%';]
                end
            end
        end 
    end
end

def registry(translation)
    File.open('pxc.sql', 'w') do |f|
        translation.each do |customer,map|
            f.puts %Q{select now(),'#{customer}';}
            map.each do |to_from|
                curr, newn = to_from
                if newn == :expired
                    f.puts %Q[update data__#{customer}.items set visible=0, reporting=0, loading=0 where string = 'tsm_#{curr}';]
                else
                    f.puts %Q[update data__#{customer}.items set string=REPLACE(string,'tsm_#{curr}','tsm_#{newn}') where string like ('tsm_#{curr}%');]
                end
            end
        end
    end
end

api = Galileo::Application::API.new

api.user_login #( username: username, password: password)

translation = {}

api.sites[:data].keys.each do |site|
    db = "data__#{site}"
    get_keys_sql = %Q[select distinct key from #{db}.__items where type = 'tsminstance';]
    api.user_login( customer: site )
    result = api.state.clickhouse.site.query(get_keys_sql)
    if result.any?
        keys = result.to_a.map do |o| 
            curr = o.last.split('tsm_').last
            newn = TRANSLATION_MAP[curr]
            if curr.include?('-')
                STDERR.puts "This looks to be a new key: #{site}/#{curr}"
                next
            elsif newn.nil?
                raise "found key #{curr} in db but not in map"
            else
                [ curr, newn ]
            end
        end
        keys.compact!
        translation.store(site,keys) if keys.length != 0
    end
end

clickhouse(translation)
registry(translation)
ap translation
    
