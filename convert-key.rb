require 'galileo/config'
require 'galileo/registry'
require 'galileo/clickhouse'
require 'awesome_print'
#require 'galileo/gpe/database/column'
#require 'galileo/gpe/database/source'
#require 'galileo/gpe/database/records/item'
#require 'galileo/gpe/database/records/relationship'
#require 'galileo/gpe/database/records/config'
#require 'galileo/gpe/database/records/trend'
#require 'galileo/gpe/database/records/transient'
#require 'galileo/gpe/database/data'



# reg_opt = Galileo.config['registry']
# ch_opt = Galileo.config['clickhouse']

# registry = Galileo::Registry.new( reg_opt )
# ch = Galileo::Clickhouse.new( ch_opt )


# ap registry.methods - Object.methods


customers = %w[
    data__Analysis_Group
    data__Anthem
    data__Carhartt
    data__Census_Bureau
    data__DandH
    data__Endo
    data__Excellus
    data__Fairfax_County
    data__LISD
    data__LoadRawData
    data__Mapfre
    data__MedHost
    data__Prudential
    data__Schonfeld
    data__Sirius_TCH
    data__Sirius_TST
    data__agelwarg
    data__alarosa
    data__atsgroup
    data__atsgroup_summarized
    data__clickhouse
    data__corr_test
    data__gn_test2
    data__gn_testing
    data__jsipling
    data__jtroy
    data__ksoskin
    data__max_test
    data__max_test2
    data__perf_test
    data__psurampudi
    data__rdavis2
    data__santo
    data__snow
    data__tsm
    data__tsm_test
    data__welchs
]

get_keys_from_ch = customers.map do |customer|
    ch = %Q[select '#{customer}' customer , key from #{customer}.__items where type like 'tsminstance' group by customer, key FORMAT CSV;]
end

# Will return, for each customer
# "data__rdavis2","tsm_c62428e0-9e0e-92ea-163c-54c826c35995"
# "data__rdavis2","tsm_563d881b-17da-64d1-0970-dfa54939f821"

# Translate the "old": "new" key
translation = [
    "data__rdavis2": {
        "tsm_c62428e0-9e0e-92ea-163c-54c826c35995" => "tsm_new1",
        "tsm_563d881b-17da-64d1-0970-dfa54939f821" => "tsm_new2"
    }
]

# Clickhouse Update
translation.each do |customer|
    customer.each do |customer, translate|
        translate.each do |old,new|
            puts %Q[alter table #{customer}.__items update key=replaceOne(key,'#{old}','#{new}') where key like '#{old}%';]
        end
    end
end 

# Registry Update
translation.each do |customer|
    customer.each do |customer, translate|
        translate.each do |old,new|
            puts %Q[update #{customer}.items set string=REPLACE(string,'#{old}','#{new}') where string like ('#{old}%');]
        end
    end
end 

# PXC Transation
# update items set string=REPLACE(string,'tsm_c4c068e67ece11e19d42000315000000','tsm_MY_NEW_ONE') where string like ('tsm_c4c068e67ece11e19d42000315000000%');

