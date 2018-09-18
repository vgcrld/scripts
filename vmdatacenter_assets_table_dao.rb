class VmwareDatacenterAssetsTableDAO < InfoTableItemsDAO
  @db_types = :vmwaredatacenter
  @db_tags = "VMWAREDATACENTER@LAYER"

  @columns_to_get = InfoTableColumns.new([
    InfoTableItemsColumn.new(:CfgVmDatacenterVcenterCfgName),
    InfoTableItemsColumn.new(:vmwarevcenter_id,     :data_type => :number_0,  :fetch => :typedagg_24_max_vmwaredatacenter),
    InfoTableItemsColumn.new(:CfgName),
    InfoTableItemsColumn.new(:VMDATACENTERvmopNumvmotionLatest, :data_type => :number_0, :fetch => :typedagg_24_min_vmwaredatacenter),
    InfoTableItemsColumn.new(:VMDATACENTERvmopNumvmotionLatest, :data_type => :number_0, :fetch => :typedagg_24_max_vmwaredatacenter),
    InfoTableItemsColumn.new(:CfgVmDatacenterTotalDatastores, :data_type => :number),
    InfoTableItemsColumn.new(:CfgVmDatacenterTotalClusters, :data_type => :number),
    InfoTableItemsColumn.new(:CfgVmDatacenterTotalHosts, :data_type => :number),
    InfoTableItemsColumn.new(:CfgVmDatacenterTotalGuests, :data_type => :number),
  ])

  @lambda_post_data_api = lambda do |data|

    min = data[:typedagg_24_min_vmwaredatacenter_VMDATACENTERvmopNumvmotionLatest][:value].to_f
    max = data[:typedagg_24_max_vmwaredatacenter_VMDATACENTERvmopNumvmotionLatest][:value].to_f
    pct = ((1-(min/max)) * 100).to_f.round(2)
    {
      :config_CfgDatacenterPctVmotion24HourChange => {
        :value  => pct,
        :pretty => pct
      }
    }
  end

  @columns_to_serve = @columns_to_get.dup
  @columns_to_serve.insert(9, InfoTableItemsColumn.new(:CfgDatacenterPctVmotion24HourChange, :data_type => :percent_3))
  @columns_to_serve.delete(
    "agg_24_min_VMDATACENTERvmopNumvmotionLatest",
    "agg_24_max_VMDATACENTERvmopNumvmotionLatest"
  )

  @columns_to_serve.make_gpe_link_column("config_CfgName", :id)
  @columns_to_serve.make_gpe_link_column("config_CfgVmDatacenterVcenterCfgName", :trend_vmwarevcenter_id)

end
