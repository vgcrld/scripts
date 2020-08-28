#!/usr/bin/env ruby

require 'galileo/application/api'

MAP = {
  'cc83aceacf83e6119c673cfdfe02e7c2' => '4211b3db-cceb-fdd0-7b90-2315d61cf298',
  'f3e50b7ec73911dbb6b826a30cf91b04' => '0029f88e-57ce-5861-0299-a12ba31570f9',
  '0000000048fa11dd94b408630a140021' => '87993a2e-5816-7f68-81d3-d5f1b0e652a9',
  'c4c068e67ece11e19d42000315000000' => 'dc26c19a-f1ea-eecf-8e13-1c2d79f2b43c',
  '5ab25322eb0ce811a58e7cd30aea05f0' => '870b246b-4a3d-2011-8454-df2cb2b1feec',
  'a46df78a0f3eea11acb33868dd1ca649' => '4b64733d-78e1-545a-f5aa-e119043bbf96',
  'f2d2bef01af811df8bd9009a01040000' => '63cf2b7d-bb41-40ca-f635-73d3c075c20e',
  '3ea0fe138b9be6119d78e0071bf7e520' => '50479a5b-9b08-c45f-abd4-f4c709677ba5',
  '488ae82b8b9be611a1a4e0071bf70b64' => '387b7540-b819-542b-b19d-f9ab977fdee4',
  '3ea0fe138b9be6119d78e0071bf7e520' => '9e0fe4a2-e025-c88c-fcdb-c19ce44cfb35',
  'a64fbe739e9de511a5f80025b50a006d' => '3d7ef905-061b-1af7-bf14-2d24d40e9883',
  '60e527c0992de611bc580025b50401ff' => 'c39710bb-c78e-1e78-7f81-61f22e32f19f',
  'b64c1f141101e811959b0025b5a4005d' => '9efc59d3-1693-75aa-4d54-c544ff21fbef',
  '12e8e2453183ea11892e3868dd205f50' => '6236d25a-11e7-bfde-2f90-e51f0f88fd5d',
  'd60b21da185e11e682260894ef035c20' => :expired
}

def get_credentials
    config   = YAML.load_file(ENV['GALILEO_CONFIG'] || "#{ENV['HOME']}/.galileo") || {} rescue {}
    username = ENV['GALILEO_USERNAME'] || config['username']
    password = ENV['GALILEO_PASSWORD'] || config['password']
    token    = ENV['GALILEO_TOKEN']    || config['token']
    return username, password, token
end

username, password, token = get_credentials

api = Galileo::Application::API.new

api.user_login( username: username, password: password)

translation = {}

# sites = api.sites[:data].keys
sites = ['tsm_test']
sites.each do |site|
    db = "data__#{site}"
    get_keys_sql = %Q[select '#{site}' customer , key from #{db}.__items where type like 'tsminstance' group by customer, key;]
    api.user_login( username: username, password: password, customer: site )
    result = api.state.clickhouse.site.query(get_keys_sql)
    if result.any?
        keys = result.to_a.map do |o| 
            curr = o.last.split('tsm_').last
            newn = MAP[curr]
            if curr.include?('-')
                puts "This looks to be a new key: #{site}/#{curr}"
                next
            else
                [ curr, newn ]
            end
        end
        keys.compact!
        translation.store(site,keys) if keys.length != 0
    end
end

# Clickhouse Update
puts "CLICKHOUSE " * 10
translation.each do |customer,map|
    map.each do |to_from|
        curr, newn = to_from
        if newn == :expired
            puts %Q[alter table data__#{customer}.__items update visible=0, reporting=0, loading=0 where key = 'tsm_#{curr}';]
        else
            puts %Q[alter table data__#{customer}.__items update key=replaceOne(key,'tsm_#{curr}','tsm_#{newn}') where key like 'tsm_#{curr}%';]
        end
    end
end 


# Registry Update
puts "PXC " * 20
translation.each do |customer,map|
    map.each do |to_from|
        curr, newn = to_from
        if newn == :expired
            puts %Q[update data__#{customer}.items set visible=0, reporting=0, loading=0 where string = 'tsm_#{curr}';]
        else
            puts %Q[update data__#{customer}.items set string=REPLACE(string,'tsm_#{curr}','tsm_#{newn}') where string like ('tsm_#{curr}%');]
        end
    end
end 

# PXC Transation
# update items set string=REPLACE(string,'tsm_c4c068e67ece11e19d42000315000000','tsm_MY_NEW_ONE') where string like ('tsm_c4c068e67ece11e19d42000315000000%');



# [  0]                             add_api_token(*args) Galileo::Application::API
# [  1]                            add_custom_tag(*args) Galileo::Application::API
# [  2]                      add_custom_tag_group(*args) Galileo::Application::API
# [  3]              add_custom_tag_with_selector(*args) Galileo::Application::API
# [  4]                              add_etl_rule(*args) Galileo::Application::API
# [  5]                  add_items_to_custom_tags(*args) Galileo::Application::API
# [  6]                                 add_roles(*args) Galileo::Application::API
# [  7]                                  add_site(*args) Galileo::Application::API
# [  8]                       add_timed_api_token(*args) Galileo::Application::API
# [  9]                      admin_reset_password(*args) Galileo::Application::API
# [ 10]                    analytics_chart_report(*args) Galileo::Application::API
# [ 11]                   analytics_create_report(*args) Galileo::Application::API
# [ 12]             analytics_create_report_group(*args) Galileo::Application::API
# [ 13]                   analytics_delete_report(*args) Galileo::Application::API
# [ 14]             analytics_delete_report_group(*args) Galileo::Application::API
# [ 15]                      analytics_map_report(*args) Galileo::Application::API
# [ 16]                   analytics_modify_report(*args) Galileo::Application::API
# [ 17]             analytics_modify_report_group(*args) Galileo::Application::API
# [ 18]                      analytics_pie_report(*args) Galileo::Application::API
# [ 19]                     analytics_report_info(*args) Galileo::Application::API
# [ 20]                    analytics_rules_report(*args) Galileo::Application::API
# [ 21]                    analytics_table_report(*args) Galileo::Application::API
# [ 22]                analytics_time_line_report(*args) Galileo::Application::API
# [ 23]                               api_version(*args) Galileo::Application::API
# [ 24]                                asset_info(*args) Galileo::Application::API
# [ 25]                      cache_generated_tags(*args) Galileo::Application::API
# [ 26]       create_correlation_job_for_customer(*args) Galileo::Application::API
# [ 27] create_correlation_jobs_for_all_customers(*args) Galileo::Application::API
# [ 28]                 create_merge_points_batch(*args) Galileo::Application::API
# [ 29]                             create_ticket(*args) Galileo::Application::API
# [ 30]                                  customer(*args) Galileo::Application::API
# [ 31]                             customer_info(*args) Galileo::Application::API
# [ 32]                       customer_trial_info(*args) Galileo::Application::API
# [ 33]                         delete_etl_errors(*args) Galileo::Application::API
# [ 34]               delete_generated_tags_cache(*args) Galileo::Application::API
# [ 35]                 delete_merge_points_batch(*args) Galileo::Application::API
# [ 36]                       disable_custom_data(*args) Galileo::Application::API
# [ 37]                        enable_custom_data(*args) Galileo::Application::API
# [ 38]                    exec_correlation_plans(*args) Galileo::Application::API
# [ 39]                          expire_api_token(*args) Galileo::Application::API
# [ 40]                  find_merge_point_batches(*args) Galileo::Application::API
# [ 41]               find_merge_point_candidates(*args) Galileo::Application::API
# [ 42]                        find_user_sessions(*args) Galileo::Application::API
# [ 43]                     get_analytics_reports(*args) Galileo::Application::API
# [ 44]                            get_api_tokens(*args) Galileo::Application::API
# [ 45]                                 get_asset(*args) Galileo::Application::API
# [ 46]                 get_custom_tag_group_info(*args) Galileo::Application::API
# [ 47]                     get_custom_tag_groups(*args) Galileo::Application::API
# [ 48]                       get_custom_tag_info(*args) Galileo::Application::API
# [ 49]                           get_custom_tags(*args) Galileo::Application::API
# [ 50]                    get_key_based_children(*args) Galileo::Application::API
# [ 51]                        get_missing_assets(*args) Galileo::Application::API
# [ 52]           get_structured_user_preferences(*args) Galileo::Application::API
# [ 53]                                get_ticket(*args) Galileo::Application::API
# [ 54]                               get_tickets(*args) Galileo::Application::API
# [ 55]             get_tickets_for_all_customers(*args) Galileo::Application::API
# [ 56]                             get_timerange(*args) Galileo::Application::API
# [ 57]                             get_timezones(*args) Galileo::Application::API
# [ 58]                                      help()      Galileo::Application::API
# [ 59]                          import_etl_rules(*args) Galileo::Application::API
# [ 60]                              invite_users(*args) Galileo::Application::API
# [ 61]                  item_count_from_selector(*args) Galileo::Application::API
# [ 62]                    item_ids_from_selector(*args) Galileo::Application::API
# [ 63]                            list_etl_rules(*args) Galileo::Application::API
# [ 64]                                 lock_site(*args) Galileo::Application::API
# [ 65]                prospect_validate_prospect(*args) Galileo::Application::API
# [ 66]       provision_prospect_distination_user(*args) Galileo::Application::API
# [ 67]                         remove_custom_tag(*args) Galileo::Application::API
# [ 68]                   remove_custom_tag_group(*args) Galileo::Application::API
# [ 69]                           remove_etl_rule(*args) Galileo::Application::API
# [ 70]             remove_items_from_custom_tags(*args) Galileo::Application::API
# [ 71]                              remove_roles(*args) Galileo::Application::API
# [ 72]                               remove_site(*args) Galileo::Application::API
# [ 73]                              remove_users(*args) Galileo::Application::API
# [ 74]                         rename_custom_tag(*args) Galileo::Application::API
# [ 75]                   rename_custom_tag_group(*args) Galileo::Application::API
# [ 76]                          retry_etl_errors(*args) Galileo::Application::API
# [ 77]                                     roles(*args) Galileo::Application::API
# [ 78]                          search_etl_queue(*args) Galileo::Application::API
# [ 79]                           set_asset_alias(*args) Galileo::Application::API
# [ 80]                  set_items_in_custom_tags(*args) Galileo::Application::API
# [ 81]                          set_items_status(*args) Galileo::Application::API
# [ 82]                           set_site_status(*args) Galileo::Application::API
# [ 83]           set_structured_user_preferences(*args) Galileo::Application::API
# [ 84]                             set_trial_end(*args) Galileo::Application::API
# [ 85]                                 site_info(*args) Galileo::Application::API
# [ 86]                          site_permissions(*args) Galileo::Application::API
# [ 87]                                site_users(*args) Galileo::Application::API
# [ 88]                                     sites(*args) Galileo::Application::API
# [ 89]                                     state()      Galileo::Application::API
# [ 90]                  structured_related_items(*args) Galileo::Application::API
# [ 91]                 structured_selected_items(*args) Galileo::Application::API
# [ 92]                               unlock_site(*args) Galileo::Application::API
# [ 93]                   user_has_access_to_site(*args) Galileo::Application::API
# [ 94]                 user_is_reset_token_valid(*args) Galileo::Application::API
# [ 95]                                user_login(*args) Galileo::Application::API
# [ 96]                               user_logout(*args) Galileo::Application::API
# [ 97]    user_management_get_editable_user_list(*args) Galileo::Application::API
# [ 98]           user_management_get_user_detail(*args) Galileo::Application::API
# [ 99]               user_management_invite_user(*args) Galileo::Application::API
# [100]       user_management_password_reset_link(*args) Galileo::Application::API
# [101]         user_management_revoke_all_access(*args) Galileo::Application::API
# [102]                user_management_set_access(*args) Galileo::Application::API
# [103]             user_management_temp_password(*args) Galileo::Application::API
# [104]         user_request_password_reset_token(*args) Galileo::Application::API
# [105]            user_reset_password_with_token(*args) Galileo::Application::API
# [106]                         user_set_password(*args) Galileo::Application::API
# [107]                          userid_available(*args) Galileo::Application::API
# [108]                             userid_exists(*args) Galileo::Application::API
# [109]                                     users(*args) Galileo::Application::API
# [110]                            users_for_site(*args) Galileo::Application::API