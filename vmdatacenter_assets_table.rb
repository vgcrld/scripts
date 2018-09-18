class VmwareDatacenterAssetsTable < InfoTable
  @title_key = 'config.table.title.vmdatacenters'
  @dao = VmwareDatacenterAssetsTableDAO
  @columns = make_columns
  @columns.hide(
    "config_CfgVmDatacenterVcenterCfgName"
  )
  @columns.delete(
    "trend_vmwarevcenter_id"
  )
  @columns.set_sort(
    ["config_CfgName", "asc"],
  )
end
