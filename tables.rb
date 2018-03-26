# Pick out tables that have a related tablespace_name
pick_non_nil_tablespaces = create_order_from_match(cfg_dba_tables_raw('tablespace_name').values_at_interval, //)

tables_with_ts  = concat(
  @dbid,
  ":tablespace_",
  order(cfg_dba_tables_raw("tablespace_name"), pick_non_nil_tablespaces),
  ":owner_",
  order(cfg_dba_tables_raw("owner"), pick_non_nil_tablespaces),
  ":table_",
  order(cfg_dba_tables_raw("table_name"),pick_non_nil_tablespaces)
).values_at_interval

# Add the Table type and only tables with tablespaces
add_types :table
add_objects :table, tables_with_ts

# Config
map "table:_owner",                      order(cfg_dba_tables_raw("owner"),pick_non_nil_tablespaces)
map "table:_table_name",                 order(cfg_dba_tables_raw("table_name"),pick_non_nil_tablespaces)
map "table:_tablespace_name",            order(cfg_dba_tables_raw("tablespace_name"),pick_non_nil_tablespaces)
map "table:_cluster_name",               order(cfg_dba_tables_raw("cluster_name"),pick_non_nil_tablespaces)
map "table:_iot_name",                   order(cfg_dba_tables_raw("iot_name"),pick_non_nil_tablespaces)
#map "table:_status",                     order(cfg_dba_tables_raw("status"),pick_non_nil_tablespaces)
#map "table:_pct_free",                   order(cfg_dba_tables_raw("pct_free"),pick_non_nil_tablespaces)
#map "table:_pct_used",                   order(cfg_dba_tables_raw("pct_used"),pick_non_nil_tablespaces)
#map "table:_ini_trans",                  order(cfg_dba_tables_raw("ini_trans"),pick_non_nil_tablespaces)
#map "table:_max_trans",                  order(cfg_dba_tables_raw("max_trans"),pick_non_nil_tablespaces)
#map "table:_initial_extent",             order(cfg_dba_tables_raw("initial_extent"),pick_non_nil_tablespaces)
#map "table:_next_extent",                order(cfg_dba_tables_raw("next_extent"),pick_non_nil_tablespaces)
#map "table:_min_extents",                order(cfg_dba_tables_raw("min_extents"),pick_non_nil_tablespaces)
#map "table:_max_extents",                order(cfg_dba_tables_raw("max_extents"),pick_non_nil_tablespaces)
#map "table:_pct_increase",               order(cfg_dba_tables_raw("pct_increase"),pick_non_nil_tablespaces)
#map "table:_freelists",                  order(cfg_dba_tables_raw("freelists"),pick_non_nil_tablespaces)
#map "table:_freelist_groups",            order(cfg_dba_tables_raw("freelist_groups"),pick_non_nil_tablespaces)
#map "table:_logging",                    order(cfg_dba_tables_raw("logging"),pick_non_nil_tablespaces)
#map "table:_backed_up",                  order(cfg_dba_tables_raw("backed_up"),pick_non_nil_tablespaces)
#map "table:_num_rows",                   order(cfg_dba_tables_raw("num_rows"),pick_non_nil_tablespaces)
#map "table:_blocks",                     order(cfg_dba_tables_raw("blocks"),pick_non_nil_tablespaces)
#map "table:_empty_blocks",               order(cfg_dba_tables_raw("empty_blocks"),pick_non_nil_tablespaces)
#map "table:_avg_space",                  order(cfg_dba_tables_raw("avg_space"),pick_non_nil_tablespaces)
#map "table:_chain_cnt",                  order(cfg_dba_tables_raw("chain_cnt"),pick_non_nil_tablespaces)
#map "table:_avg_row_len",                order(cfg_dba_tables_raw("avg_row_len"),pick_non_nil_tablespaces)
#map "table:_avg_space_freelist_blocks",  order(cfg_dba_tables_raw("avg_space_freelist_blocks"),pick_non_nil_tablespaces)
#map "table:_num_freelist_blocks",        order(cfg_dba_tables_raw("num_freelist_blocks"),pick_non_nil_tablespaces)
#map "table:_degree",                     order(cfg_dba_tables_raw("degree"),pick_non_nil_tablespaces)
#map "table:_instances",                  order(cfg_dba_tables_raw("instances"),pick_non_nil_tablespaces)
#map "table:_cache",                      order(cfg_dba_tables_raw("cache"),pick_non_nil_tablespaces)
#map "table:_table_lock",                 order(cfg_dba_tables_raw("table_lock"),pick_non_nil_tablespaces)
#map "table:_sample_size",                order(cfg_dba_tables_raw("sample_size"),pick_non_nil_tablespaces)
#map "table:_last_analyzed",              order(cfg_dba_tables_raw("last_analyzed"),pick_non_nil_tablespaces)
#map "table:_partitioned",                order(cfg_dba_tables_raw("partitioned"),pick_non_nil_tablespaces)
#map "table:_iot_type",                   order(cfg_dba_tables_raw("iot_type"),pick_non_nil_tablespaces)
#map "table:_temporary",                  order(cfg_dba_tables_raw("temporary"),pick_non_nil_tablespaces)
#map "table:_secondary",                  order(cfg_dba_tables_raw("secondary"),pick_non_nil_tablespaces)
#map "table:_nested",                     order(cfg_dba_tables_raw("nested"),pick_non_nil_tablespaces)
#map "table:_buffer_pool",                order(cfg_dba_tables_raw("buffer_pool"),pick_non_nil_tablespaces)
#map "table:_flash_cache",                order(cfg_dba_tables_raw("flash_cache"),pick_non_nil_tablespaces)
#map "table:_cell_flash_cache",           order(cfg_dba_tables_raw("cell_flash_cache"),pick_non_nil_tablespaces)
#map "table:_row_movement",               order(cfg_dba_tables_raw("row_movement"),pick_non_nil_tablespaces)
#map "table:_global_stats",               order(cfg_dba_tables_raw("global_stats"),pick_non_nil_tablespaces)
#map "table:_user_stats",                 order(cfg_dba_tables_raw("user_stats"),pick_non_nil_tablespaces)
#map "table:_duration",                   order(cfg_dba_tables_raw("duration"),pick_non_nil_tablespaces)
#map "table:_skip_corrupt",               order(cfg_dba_tables_raw("skip_corrupt"),pick_non_nil_tablespaces)
#map "table:_monitoring",                 order(cfg_dba_tables_raw("monitoring"),pick_non_nil_tablespaces)
#map "table:_cluster_owner",              order(cfg_dba_tables_raw("cluster_owner"),pick_non_nil_tablespaces)
#map "table:_dependencies",               order(cfg_dba_tables_raw("dependencies"),pick_non_nil_tablespaces)
#map "table:_compression",                order(cfg_dba_tables_raw("compression"),pick_non_nil_tablespaces)
#map "table:_compress_for",               order(cfg_dba_tables_raw("compress_for"),pick_non_nil_tablespaces)
#map "table:_dropped",                    order(cfg_dba_tables_raw("dropped"),pick_non_nil_tablespaces)
#map "table:_read_only",                  order(cfg_dba_tables_raw("read_only"),pick_non_nil_tablespaces)
#map "table:_segment_created",            order(cfg_dba_tables_raw("segment_created"),pick_non_nil_tablespaces)
#map "table:_result_cache",               order(cfg_dba_tables_raw("result_cache"),pick_non_nil_tablespaces)

export_config :oracletables,
  :CfgOracleTableOwner         => "table:_owner",
  :CfgOracleTableName          => "table:_table_name",
  :CfgOracleTablespaceName     => "table:_tablespace_name",
  :CfgOracleTableClusterName   => "table:_cluster_name"

# Tag
export_tag :oracletable, :add => "table:TABLE@ORACLE"

# set the parent
#    Databse Parent: "oracledatabase_923934-2039173335"
# Tablespace Parent: "oracledatabase_923934-2039173335:tablespace_SYSAUX"
#       User Parent: "oracledatabase_923934-2039173335:user_54"
pick_users = order_objects(
  (user :_username).merge_values_for_intervals,
  (table :_owner).merge_values_for_intervals,
  equal: false
)
pick_tablespaces = order_objects(
  (tablespace :_tablespace_name).merge_values_for_intervals,
  (table :_tablespace_name).merge_values_for_intervals,
  equal: false
)

require 'debug'

map_by_interval "table:_database_parent",   @shifted_intervals, @dbid
map_by_interval "table:_tablespace_parent", @shifted_intervals, @dbid
map_by_interval "table:_user_parent",       @shifted_intervals, @dbid

export_relative :oracletablespace, :oracledatabase   => "tablespace:_database_parent"
export_relative :oracletablespace, :oracletablespace => "tablespace:_tablespace_parent"
export_relative :oracletablespace, :oracleuser       => "tablespace:_user_parent"

# Ensure at least one trend record
map_by_interval ("tablespace:_empty"), @shifted_intervals, 0.0
export_trend :oracletablespace, :_empty => "tablespace:_empty"
