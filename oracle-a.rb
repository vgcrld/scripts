#  Define our collections
#
$collected_reports["Oracle"] ||= Array.new

# Selectors
#
oracle_tbsp_selector      = Galileo::DB::Alert::Selector::Tag.new(["TABLESPACE@ORACLE"])
oracle_inst_selector      = Galileo::DB::Alert::Selector::Tag.new(["INSTANCE@ORACLE"])
oracle_asm_dg_selector    = Galileo::DB::Alert::Selector::Tag.new(["ASMDISKGROUP@ORACLE"])
oracle_ctrl_file_selector = Galileo::DB::Alert::Selector::Tag.new(["CONTROLFILE@ORACLE"])
oracle_log_file_selector  = Galileo::DB::Alert::Selector::Tag.new(["LOGFILE@ORACLE"])

pga_cache_hit_ratio_def = {
  :type                => "oracleinstance",
  :master_type         => "oracledatabase",
  :condition_type      => "Memory",
  :formula             => "ORACLEInstancePgaCacheHitRatio < __min__",
  :name                => "PGA Cache Hit Ratio under __min__%",
  :display_name        => "PGA Cache Hit Ratio under __min__%",
  :display_formula     => "PGA Cache Hit Ratio under __min__%",
  :custom_vars         => [Galileo::DB::Alert::Health::CustomVariableDefinition.new('min', 99.0, nil, :percent)],
  :min_duration        => 3700,
  :charts              => [Galileo::DB::Alert::Health::ChartDefinition.new(52044, :master_id)],
}

pga_cache_hit_ratio_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_inst_selector])
pga_cache_hit_ratio                = Galileo::DB::Alert::Health::Condition::ConditionSQL.new(pga_cache_hit_ratio_def)
$collected_reports["Oracle"].push(pga_cache_hit_ratio)


buffer_cache_hit_ratio_def = {
  :type                => "oracleinstance",
  :master_type         => "oracledatabase",
  :condition_type      => "Memory",
  :formula             => "ORACLEInstanceBufferCacheHitRatio < __min__",
  :name                => "Buffer Cache Hit Ratio under __min__%",
  :display_name        => "Buffer Cache Hit Ratio under __min__%",
  :display_formula     => "Buffer Cache Hit Ratio under __min__%",
  :custom_vars         => [Galileo::DB::Alert::Health::CustomVariableDefinition.new('min', 99.0, nil, :percent)],
  :min_duration        => 3700,
  :charts              => [Galileo::DB::Alert::Health::ChartDefinition.new(52043, :master_id)],
}

buffer_cache_hit_ratio_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_inst_selector])
buffer_cache_hit_ratio                = Galileo::DB::Alert::Health::Condition::ConditionSQL.new(buffer_cache_hit_ratio_def)
$collected_reports["Oracle"].push(buffer_cache_hit_ratio)


library_cache_hit_ratio_def = {
  :type                => "oracleinstance",
  :master_type         => "oracledatabase",
  :condition_type      => "Memory",
  :formula             => "ORACLEInstanceLibraryCacheHitRatio < __min__",
  :name                => "Library Cache Hit Ratio under __min__%",
  :display_name        => "Library Cache Hit Ratio under __min__%",
  :display_formula     => "Library Cache Hit Ratio under __min__%",
  :custom_vars         => [Galileo::DB::Alert::Health::CustomVariableDefinition.new('min', 90.0, nil, :percent)],
  :min_duration        => 3700,
  :charts              => [Galileo::DB::Alert::Health::ChartDefinition.new(52045, :master_id)],
}

library_cache_hit_ratio_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_inst_selector])
library_cache_hit_ratio                = Galileo::DB::Alert::Health::Condition::ConditionSQL.new(library_cache_hit_ratio_def)
$collected_reports["Oracle"].push(library_cache_hit_ratio)


row_cache_hit_ratio_def = {
  :type                => "oracleinstance",
  :master_type         => "oracledatabase",
  :condition_type      => "Memory",
  :formula             => "ORACLEInstanceRowCacheHitRatio < __min__",
  :name                => "Row Cache Hit Ratio under __min__%",
  :display_name        => "Row Cache Hit Ratio under __min__%",
  :display_formula     => "Row Cache Hit Ratio under __min__%",
  :custom_vars         => [Galileo::DB::Alert::Health::CustomVariableDefinition.new('min', 90.0, nil, :percent)],
  :min_duration        => 3700,
  :charts              => [Galileo::DB::Alert::Health::ChartDefinition.new(52046, :master_id)],
}

row_cache_hit_ratio_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_inst_selector])
row_cache_hit_ratio                = Galileo::DB::Alert::Health::Condition::ConditionSQL.new(row_cache_hit_ratio_def)
$collected_reports["Oracle"].push(row_cache_hit_ratio)
#  Define our collections
#
$collected_reports["Oracle"] ||= Array.new

# Selectors
#
oracle_tbsp_selector      = Galileo::DB::Alert::Selector::Tag.new(["TABLESPACE@ORACLE"])
oracle_users_selector     = Galileo::DB::Alert::Selector::Tag.new(["USER@ORACLE"])
oracle_inst_selector      = Galileo::DB::Alert::Selector::Tag.new(["INSTANCE@ORACLE"])
oracle_asm_dg_selector    = Galileo::DB::Alert::Selector::Tag.new(["ASMDISKGROUP@ORACLE"])
oracle_ctrl_file_selector = Galileo::DB::Alert::Selector::Tag.new(["CONTROLFILE@ORACLE"])
oracle_log_file_selector  = Galileo::DB::Alert::Selector::Tag.new(["LOGFILE@ORACLE"])
oracle_datafile_selector  = Galileo::DB::Alert::Selector::Tag.new(["DATAFILE@ORACLE"])



#################
# OBJECTS PANEL #
#################

datafile_gt_than_def = {
  :type                => "oracledatafile",
  :master_type         => "oracledatabase",
  :condition_type      => "Objects",
  :formula             => "(ORACLEDatafileFreeMb / ORACLEDatafileMb) * 100 >= __warn__",
  :name                => "Tablespaces >= __warn__%",
  :display_name        => "Tablespaces >= __warn__%",
  :display_formula     => "Tablespaces >= __warn__%",
  :crit_value          => 80,
  :thresholds          => {52080 => {:orange => "__warn__", :red => "__max__"}},
  :custom_vars         => [
                            Galileo::DB::Alert::Health::CustomVariableDefinition.new('warn',  75, nil, :percent),
                            Galileo::DB::Alert::Health::CustomVariableDefinition.new('max',   80, nil, :percent)
                          ],
  :charts              => [Galileo::DB::Alert::Health::ChartDefinition.new(52080, :master_id)],
}

datafile_gt_than_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_datafile_selector])
datafile_gt_than                = Galileo::DB::Alert::Health::Condition::ConditionSQL.new(datafile_gt_than_def)
$collected_reports["Oracle"].push(datafile_gt_than)

tables_readonly_def = {
  :type                => "oracletablespace",
  :master_type         => "oracledatabase",
  :condition_type      => "Objects",
  :formula             => "__tablestatus__ != 'ONLINE'",
  :name                => "Tablespaces which are read only",
  :display_name        => "Tablespaces which are read only",
  :display_formula     => "Tablespaces which are read only",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("tablestatus",   ["CfgOracleTablespaceStatus"], "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",          ["CfgName"],                   "item_id"),
  ],
  :message             => "__name__ has a tablespace status of __tablestatus__"
}

tables_readonly_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_tbsp_selector])
tables_readonly                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(tables_readonly_def)
$collected_reports["Oracle"].push(tables_readonly)



tables_5d_analyzed_def = {
  :type                => "",
  :master_type         => "",
  :condition_type      => "Objects",
  :formula             => "",
  :name                => "Tables more than 7 days since analyzed",
  :display_name        => "Tables more than 7 days since analyzed",
  :display_formula     => "Tables more than 7 days since analyzed",
  :config_vars         => [ ],
  :charts              => [ ],
  :message             => ""
}

tables_5d_analyzed_def[:selector] = Galileo::DB::Alert::Selector::And.new([])
tables_5d_analyzed                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(tables_5d_analyzed_def)
#$collected_reports["Oracle"].push(tables_5d_analyzed)



tables_2gb_partitioned_def = {
  :type                => "",
  :master_type         => "",
  :condition_type      => "Objects",
  :formula             => "",
  :name                => "Tables >= 2 GB in total size, should be partitioned",
  :display_name        => "Tables >= 2 GB in total size, should be partitioned",
  :display_formula     => "Tables >= 2 GB in total size, should be partitioned",
  :config_vars         => [ ],
  :charts              => [ ],
  :message             => ""
}

tables_2gb_partitioned_def[:selector] = Galileo::DB::Alert::Selector::And.new([])
tables_2gb_partitioned                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(tables_2gb_partitioned_def)
#$collected_reports["Oracle"].push(tables_2gb_partitioned)



views_invalid_def = {
  :type                => "",
  :master_type         => "",
  :condition_type      => "Objects",
  :formula             => "",
  :name                => "",
  :display_name        => "",
  :display_formula     => "",
  :config_vars         => [ ],
  :charts              => [ ],
  :message             => ""
}

views_invalid_def[:selector] = Galileo::DB::Alert::Selector::And.new([])
views_invalid                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(views_invalid_def)
#$collected_reports["Oracle"].push(views_invalid)



pl_sql_pkg_invalid_def = {
  :type                => "",
  :master_type         => "",
  :condition_type      => "Objects",
  :formula             => "",
  :name                => "",
  :display_name        => "",
  :display_formula     => "",
  :config_vars         => [ ],
  :charts              => [ ],
  :message             => ""
}

pl_sql_pkg_invalid_def[:selector] = Galileo::DB::Alert::Selector::And.new([])
pl_sql_pkg_invalid            = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(pl_sql_pkg_invalid_def)
#$collected_reports["Oracle"].push(pl_sql_pkg_invalid)



pl_sql_pkg_bodies_invalid_def = {
  :type                => "",
  :master_type         => "",
  :condition_type      => "Objects",
  :formula             => "",
  :name                => "",
  :display_name        => "",
  :display_formula     => "",
  :config_vars         => [ ],
  :charts              => [ ],
  :message             => ""
}

pl_sql_pkg_bodies_invalid_def[:selector] = Galileo::DB::Alert::Selector::And.new([])
pl_sql_pkg_bodies_invalid            = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(pl_sql_pkg_bodies_invalid_def)
#$collected_reports["Oracle"].push(pl_sql_pkg_bodies_invalid)



pl_sql_procedures_invalid_def = {
  :type                => "",
  :master_type         => "",
  :condition_type      => "Objects",
  :formula             => "",
  :name                => "",
  :display_name        => "",
  :display_formula     => "",
  :config_vars         => [ ],
  :charts              => [ ],
  :message             => ""
}

pl_sql_procedures_invalid_def[:selector] = Galileo::DB::Alert::Selector::And.new([])
pl_sql_procedures_invalid            = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(pl_sql_procedures_invalid_def)
#$collected_reports["Oracle"].push(pl_sql_procedures_invalid)



trigger_invalid_def = {
  :type                => "",
  :master_type         => "",
  :condition_type      => "Objects",
  :formula             => "",
  :name                => "",
  :display_name        => "",
  :display_formula     => "",
  :config_vars         => [ ],
  :charts              => [ ],
  :message             => ""
}

trigger_invalid_def[:selector] = Galileo::DB::Alert::Selector::And.new([])
trigger_invalid                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(trigger_invalid_def)
#$collected_reports["Oracle"].push(trigger_invalid)



unusable_index_def = {
  :type                => "",
  :master_type         => "",
  :condition_type      => "Objects",
  :formula             => "",
  :name                => "",
  :display_name        => "",
  :display_formula     => "",
  :config_vars         => [ ],
  :charts              => [ ],
  :message             => ""
}

unusable_index_def[:selector] = Galileo::DB::Alert::Selector::And.new([])
unusable_index                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(unusable_index_def)
#$collected_reports["Oracle"].push(unusable_index)



invisible_index_def = {
  :type                => "",
  :master_type         => "",
  :condition_type      => "Objects",
  :formula             => "",
  :name                => "",
  :display_name        => "",
  :display_formula     => "",
  :config_vars         => [ ],
  :charts              => [ ],
  :message             => ""
}

invisible_index_def[:selector] = Galileo::DB::Alert::Selector::And.new([])
invisible_index                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(invisible_index_def)
#$collected_reports["Oracle"].push(invisible_index)





#################
# MEMORY  PANEL #
#################

amm_mins_def = {
  :type                => "oracleinstance",
  :master_type         => "oracledatabase",
  :condition_type      => "Memory",
  :formula             => "__amminuse__ == 'Yes' and __dbcachesize__.to_i != 0 ",
  :name                => "Memory components with minimums set while using AMM",
  :display_name        => "Memory components with minimums set while using AMM",
  :display_formula     => "Memory components with minimums set while using AMM",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("dbcachesize",   ["CfgOracleInstanceDbCacheSize"], "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("amminuse",      ["CfgOracleInstanceAmmInUse"],    "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",          ["CfgName"],                      "item_id"),
  ],
  :message             => "__name__: AMM is set __amminuse__ (MEMORY_TARGET != 0) __dbcachesize__"
}

amm_mins_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_inst_selector])
amm_mins                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(amm_mins_def)
$collected_reports["Oracle"].push(amm_mins)


pga_overallocation_def = {
  :type                => "oracleinstance",
  :master_type         => "oracledatabase",
  :condition_type      => "Memory",
  :formula             => "ORACLEInstancePgaOverAllocCount > __max__",
  :name                => "PGA Overallocation > __max__",
  :display_name        => "PGA Overallocation > __max__",
  :display_formula     => "PGA Overallocation > __max__",
  :custom_vars         => [Galileo::DB::Alert::Health::CustomVariableDefinition.new('max', 1, nil, :integer)],
  :charts              => [Galileo::DB::Alert::Health::ChartDefinition.new(52048, :master_id)],
}

pga_overallocation_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_inst_selector])
pga_overallocation                = Galileo::DB::Alert::Health::Condition::ConditionSQL.new(pga_overallocation_def)
$collected_reports["Oracle"].push(pga_overallocation)



hard_parses_count_def = {
  :type                => "oracleinstance",
  :master_type         => "oracledatabase",
  :condition_type      => "Memory",
  :formula             => "ORACLEInstanceParseCountHardPerSec > __max__",
  :name                => "Oracle hard parses > __max__",
  :display_name        => "Oracle hard parses > __max__",
  :display_formula     => "Oracle hard parses > __max__",
  :custom_vars         => [Galileo::DB::Alert::Health::CustomVariableDefinition.new('max', 1, nil, :integer)],
  :charts              => [Galileo::DB::Alert::Health::ChartDefinition.new(52091, :master_id, {:selected_series_type => "ORACLEInstanceParseCountHardPerSec"})],
}

hard_parses_count_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_inst_selector])
hard_parses_count                = Galileo::DB::Alert::Health::Condition::ConditionSQL.new(hard_parses_count_def)
$collected_reports["Oracle"].push(hard_parses_count)




############
# SESSIONS #
############
sessions_of_max_def = {
  :type                => "oracleinstance",
  :master_type         => "oracledatabase",
  :condition_type      => "Sessions",
  :formula             => "ORACLEInstanceActiveSessionCount > (ORACLEInstanceSessionLimit * .80)",
  :name                => "Sessions 80 % of Max",
  :display_name        => "Sessions 80 % of Max",
  :display_formula     => "Sessions 80 % of Max",
  :charts              => [Galileo::DB::Alert::Health::ChartDefinition.new(52005, :master_id)],
}

sessions_of_max_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_inst_selector])
sessions_of_max                = Galileo::DB::Alert::Health::Condition::ConditionSQL.new(sessions_of_max_def)
$collected_reports["Oracle"].push(sessions_of_max)


blocked_sessions_def = {
  :type                => "oracleinstance",
  :master_type         => "oracledatabase",
  :condition_type      => "Sessions",
  :formula             => "ORACLEInstanceActiveSessionCount > (ORACLEInstanceSessionLimit * .80)",
  :name                => "Sessions 80 % of Max",
  :display_name        => "Sessions 80 % of Max",
  :display_formula     => "Sessions 80 % of Max",
  :charts              => [Galileo::DB::Alert::Health::ChartDefinition.new(52005, :master_id)],
}

blocked_sessions_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_inst_selector])
blocked_sessions                = Galileo::DB::Alert::Health::Condition::ConditionSQL.new(blocked_sessions_def)
#$collected_reports["Oracle"].push(blocked_sessions)


################
# DISK / FILES #
################

asm_disk_groups_utilized_def = {
  :type                => "oracleasmdisk",
  :master_type         => "oracledatabase",
  :condition_type      => "Disk / Files",
  :formula             => "((__asmgrouptotal__.to_i * 1e0) - (__asmgroupfree__.to_i * 1e0)) / (__asmgrouptotal__.to_i * 1e0) > (__max__/100.0)",
  :name                => "ASM Disk Groups >=__max__% utilized",
  :display_name        => "ASM Disk Groups >=__max__% utilized",
  :display_formula     => "ASM Disk Groups >=__max__ % utilized",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("asmgroupfree",  ["CfgOracleAsmDiskGroupFreeMb"],  "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("asmgrouptotal", ["CfgOracleAsmDiskGroupTotalMb"], "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",          ["CfgName"],                      "item_id"),
  ],
  :custom_vars         => [Galileo::DB::Alert::Health::CustomVariableDefinition.new('max', 80.0, nil, :percent)],
  :crit_value          => 3,
  :thresholds          => {52047 => {:red => "__max__"}},
  :message             => "ASM disk group (__name__) is greater than __max__% utilized: free (__asmgroupfree__) total (__asmgrouptotal__)"
}

asm_disk_groups_utilized_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_asm_dg_selector])
asm_disk_groups_utilized                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(asm_disk_groups_utilized_def)
$collected_reports["Oracle"].push(asm_disk_groups_utilized)



asm_elig_but_not_mem_def = {
  :type                => "oracleasmdisk",
  :master_type         => "oracledatabase",
  :condition_type      => "Disk / Files",
  :formula             => "! __header__.nil?",
  :name                => "Eligible for ASM but not members",
  :display_name        => "Eligible for ASM but not members",
  :display_formula     => "Eligible for ASM but not members",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("header",  ["CfgOracleAsmDiskHeaderStatus"],  "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",          ["CfgName"],                 "item_id"),
  ],
  :message             => "__name__: __header__"
}

asm_elig_but_not_mem_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_asm_dg_selector])
asm_elig_but_not_mem                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(asm_elig_but_not_mem_def)
$collected_reports["Oracle"].push(asm_elig_but_not_mem)



former_asm_def = {
  :type                => "oracleasmdisk",
  :master_type         => "oracledatabase",
  :condition_type      => "Disk / Files",
  :formula             => "",
  :name                => "",
  :display_name        => "",
  :display_formula     => "",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",          ["CfgName"],                 "item_id"),
  ],
  :message             => "__name__: __header__"
}

former_asm_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_asm_dg_selector])
former_asm                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(former_asm_def)
#$collected_reports["Oracle"].push(former_asm)



tablespace_gt_utilized_def = {
  :type                => "oracleasmdisk",
  :master_type         => "oracledatabase",
  :condition_type      => "Disk / Files",
  :formula             => "",
  :name                => "",
  :display_name        => "",
  :display_formula     => "",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",          ["CfgName"],                 "item_id"),
  ],
  :message             => "__name__: __header__"
}

tablespace_gt_utilized_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_asm_dg_selector])
tablespace_gt_utilized                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(tablespace_gt_utilized_def)
$collected_reports["Oracle"].push(tablespace_gt_utilized)



tbsp_readonly_def = {
  :type                => "oracletablespace",
  :master_type         => "oracledatabase",
  :condition_type      => "Objects",
  :formula             => "true",
  :name                => "Tablespaces which are read only",
  :display_name        => "Tablespaces which are read only",
  :display_formula     => "Tablespaces which are read only",
  :config_vars         => [ ],
  :charts              => [ ],
  :message             => ""
}

tbsp_readonly_def[:selector] = Galileo::DB::Alert::Selector::And.new([])
tbsp_readonly                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(tbsp_readonly_def)
#$collected_reports["Oracle"].push(tbsp_readonly)




#########
# USERS #
#########
user_locked_def = {
  :type                => "oracleuser",
  :master_type         => "oracledatabase",
  :condition_type      => "Users",
  :formula             => "__lockedstatus__ == 'SYSTEM'",
  :name                => "Users locked out",
  :display_name        => "Users locked out",
  :display_formula     => "Users locked out",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("lockedstatus", ["CfgOracleDatabaseUserAccountStatus"], "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",         ["CfgName"],                            "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("mastername",   ["CfgName"],                            "master_id"),
  ],
  :message             => "__name__ has a status of __lockedstatus__ on __mastername__"
}

user_locked_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_users_selector])
user_locked                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(user_locked_def)
$collected_reports["Oracle"].push(user_locked)


user_system_default_def = {
  :type                => "oracleuser",
  :master_type         => "oracledatabase",
  :condition_type      => "Users",
  :formula             => "__default__ == 'SYSTEM'",
  :name                => "Database users which have SYSTEM as their default tablespace",
  :display_name        => "Database users which have SYSTEM as their default tablespace",
  :display_formula     => "Database users which have SYSTEM as their default tablespace",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("default",      ["CfgOracleDatabaseUserDefaultTablespace"], "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",         ["CfgName"],                                "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("mastername",   ["CfgName"],                                "master_id"),
  ],
  :message             => "__name__ has __default__ as their default tablespace on __mastername__"
}

user_system_default_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_users_selector])
user_system_default                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(user_system_default_def)
$collected_reports["Oracle"].push(user_system_default)


user_system_temporary_def = {
  :type                => "oracleuser",
  :master_type         => "oracledatabase",
  :condition_type      => "Users",
  :formula             => "__temp__ == 'SYSTEM'",
  :name                => "Database users which have SYSTEM as their temporary tablespace",
  :display_name        => "Database users which have SYSTEM as their temporary tablespace",
  :display_formula     => "Database users which have SYSTEM as their temporary tablespace",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("temp",         ["CfgOracleDatabaseUserTempTablespace"],    "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",         ["CfgName"],                                "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("mastername",   ["CfgName"],                                "master_id"),
  ],
  :message             => "__name__ has __temp__ as their temporary tablespace on __mastername__"
}

user_system_temporary_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_users_selector])
user_system_temporary                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(user_system_temporary_def)
$collected_reports["Oracle"].push(user_system_temporary)


user_redo_gen_def = {
  :type                => "oracletablespace",
  :master_type         => "oracledatabase",
  :condition_type      => "Objects",
  :formula             => "true",
  :name                => "",
  :display_name        => "",
  :display_formula     => "",
  :config_vars         => [ ],
  :charts              => [ ],
  :message             => ""
}

user_redo_gen_def[:selector] = Galileo::DB::Alert::Selector::And.new([])
user_redo_gen                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(user_redo_gen_def)
#$collected_reports["Oracle"].push(user_redo_gen)




#################
# Configuration #
#################
#
ctrl_files_not_multiplexed_def = {
  :type                => "oraclecontrolfile",
  :master_type         => "oracledatabase",
  :condition_type      => "Disk / Files",
  #:condition_type      => "Database Files",
  :formula             => "__ctrlfilemirror__ != 'Yes'",
  :name                => "Control files not multiplexed/mirrored",
  :display_name        => "Control files not multiplexed/mirrored",
  :display_formula     => "Control files not multiplexed/mirrored",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("ctrlfilemirror", ["CfgOracleControlFileIsMirrored"], "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",           ["CfgName"],                        "item_id"),
  ],
  :message             => "__name__ has a mirror status of: __ctrlfilemirror__"
}

ctrl_files_not_multiplexed_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_ctrl_file_selector])
ctrl_files_not_multiplexed                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(ctrl_files_not_multiplexed_def)
$collected_reports["Oracle"].push(ctrl_files_not_multiplexed)


# Online redo logs: Redo log files not multiplexed/mirrored
#
redo_files_not_multiplexed_def = {
  :type                => "oraclelogfile",
  :master_type         => "oracledatabase",
  :condition_type      => "Disk / Files",
  #:condition_type      => "Database Files",
  :formula             => "__logfilemirror__ != 'Yes'",
  :name                => "Redo log files not multiplexed/mirrored",
  :display_name        => "Redo log files not multiplexed/mirrored",
  :display_formula     => "Redo log files not multiplexed/mirrored",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("logfilemirror",  ["CfgOracleLogfileIsMirrored"], "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",           ["CfgName"],                    "item_id"),
  ],
  :message             => "__name__ has a mirror status of: __logfilemirror__"
}

redo_files_not_multiplexed_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_log_file_selector])
redo_files_not_multiplexed                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(redo_files_not_multiplexed_def)
$collected_reports["Oracle"].push(redo_files_not_multiplexed)



database_not_spfile_def = {
  :type                => "oracleinstance",
  :master_type         => "oracledatabase",
  :condition_type      => "Configurations",
  :formula             => "__spfile__.nil?",
  :name                => "Database not using an SPFILE",
  :display_name        => "Database not using an SPFILE",
  :display_formula     => "Database not using an SPFILE",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",           ["CfgName"],                 "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("spfile",         ["CfgOracleInstanceSpFile"], "item_id"),
  ],
  :message             => "__name__ does not have an SP file"
}

database_not_spfile_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_inst_selector])
database_not_spfile                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(database_not_spfile_def)
$collected_reports["Oracle"].push(database_not_spfile)


filesystemio_opts_def = {
  :type                => "oracleinstance",
  :master_type         => "oracledatabase",
  :condition_type      => "Configurations",
  :formula             => "__opt__ == 'setall'",
  :name                => "FILESYSTEMIO_OPTIONS=SETALL or DIRECTIO (for non-AIX)",
  :display_name        => "FILESYSTEMIO_OPTIONS=SETALL or DIRECTIO (for non-AIX)",
  :display_formula     => "FILESYSTEMIO_OPTIONS=SETALL or DIRECTIO (for non-AIX)",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",        ["CfgName"],                          "item_id"),
    Galileo::DB::Alert::Health::ConfigDefinition.new("opt",         ["CfgOracleInstanceFileSystemIoOpt"], "item_id"),
  ],
  :message             => "__name__ is set to __opt__"
}

filesystemio_opts_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_inst_selector])
filesystemio_opts                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(filesystemio_opts_def)
$collected_reports["Oracle"].push(filesystemio_opts)


log_archive_def = {
  :type                => "",
  :master_type         => "",
  :condition_type      => "Configurations",
  :formula             => "",
  :name                => "",
  :display_name        => "",
  :display_formula     => "",
  :config_vars         => [
    Galileo::DB::Alert::Health::ConfigDefinition.new("name",           ["CfgName"],                    "item_id"),
  ],
}

log_archive_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_log_file_selector])
log_archive                = Galileo::DB::Alert::Health::Condition::ConditionConfigCompare.new(log_archive_def)
#$collected_reports["Oracle"].push(log_archive)


#enqueue_deadlocks_def = {
#  :type                => "oracleinstance",
#  :master_type         => "oracledatabase",
#  :condition_type      => "Objects",
#  :formula             => "ORACLEInstanceEnqueueDeadlocks > __max__",
#  :name                => "Enqueue Deadlocks > __max__",
#  :display_name        => "Enqueue Deadlocks > __max__",
#  :display_formula     => "Enqueue Deadlocks > __max__",
#  :custom_vars         => [Galileo::DB::Alert::Health::CustomVariableDefinition.new('max', 1, nil, :integer)],
#  :charts              => [Galileo::DB::Alert::Health::ChartDefinition.new(52007, :master_id)],
#}
#enqueue_deadlocks_def[:selector] = Galileo::DB::Alert::Selector::And.new([oracle_inst_selector])
#enqueue_deadlocks                = Galileo::DB::Alert::Health::Condition::ConditionSQL.new(enqueue_deadlocks_def)
#$collected_reports["Oracle"].push(enqueue_deadlocks)


