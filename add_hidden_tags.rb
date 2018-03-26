class AddNetappCdotToHiddenTagsForTaggingTables20171207 < GalileoTasks::Migration

  class Customer < ActiveRecord::Base; end
  class CustomTag < ActiveRecord::Base; end
  class CustomTagGroup < ActiveRecord::Base; end

  GPE_TAGGING_SELECTOR_FOR_Storage_before           = '{"class":"tag",  "value":["DS8K@LAYER",     "CLUSTER@LAYER",  "XIV@LAYER",       "A9000@LAYER",       "SUBSYSTEM@LAYER",  "NETAPP_7M@LAYER",  "NETAPP_CDOT@LAYER", "FLASH@LAYER",  "DS8K@LAYER",        "INFINIDAT@LAYER" ]}'
  GPE_TAGGING_SELECTOR_FOR_Storage_Volumes_before   = '{"class":"tag",  "value":["VDISK@CLUSTER",  "VOLUME@XIV",     "LOGICAL@LAYER" ,  "VOLUME@NETAPP_7M",  "VOLUME@NETAPP_CDOT", "VDISK@FLASH",      "CKDVOL@DS8K",      "FBVOL@DS8K",   "VOLUME@INFINIDAT",  "FS@INFINIDAT" ]}'

  CUSTOM_TAGS_before = [
    {:name => "Storage",            :selector => GPE_TAGGING_SELECTOR_FOR_Storage_before,            :selectable => true,  :vframe => false,  :hidden => false,  :locked => true,  :internal => true,  :group => 'Galileo Assets'},
    {:name => "Storage Volumes",    :selector => GPE_TAGGING_SELECTOR_FOR_Storage_Volumes_before,    :selectable => true,  :vframe => false,  :hidden => false,  :locked => true,  :internal => true,  :group => 'Galileo Assets'},
  ]



  GPE_TAGGING_SELECTOR_FOR_Storage           = '{"class":"tag",  "value":["DS8K@LAYER",     "CLUSTER@LAYER",  "XIV@LAYER",       "A9000@LAYER",       "SUBSYSTEM@LAYER",  "NETAPP_7M@LAYER",  "NETAPP_CDOT@LAYER", "FLASH@LAYER",  "DS8K@LAYER",        "INFINIDAT@LAYER",  "VNX@LAYER", "VMAX@LAYER", "EMCUNITY@LAYER" ]}'
  GPE_TAGGING_SELECTOR_FOR_Storage_Volumes   = '{"class":"tag",  "value":["VDISK@CLUSTER",  "VOLUME@XIV",     "LOGICAL@LAYER" ,  "VOLUME@NETAPP_7M",  "VOLUME@NETAPP_CDOT", "VDISK@FLASH",      "CKDVOL@DS8K",      "FBVOL@DS8K",   "VOLUME@INFINIDAT",  "FS@INFINIDAT",     "LUN@VNX", "VOLUME@VMAX", "LUN@EMCUNITY"]}'

  CUSTOM_TAGS = [
    {:name => "Storage",            :selector => GPE_TAGGING_SELECTOR_FOR_Storage,            :selectable => true,  :vframe => false,  :hidden => false,  :locked => true,  :internal => true,  :group => 'Galileo Assets'},
    {:name => "Storage Volumes",    :selector => GPE_TAGGING_SELECTOR_FOR_Storage_Volumes,    :selectable => true,  :vframe => false,  :hidden => false,  :locked => true,  :internal => true,  :group => 'Galileo Assets'},
  ]

  def up
    add_system_tags(@db_template, 'galileo_template', CUSTOM_TAGS, hidden: false)
    # Next per customer
    Customer.all.each do |c|
      @log.info "Adding system tags/groups to #{c.customer_name}"
      schema     = c.customer_db_schema
      conn       = get_customer_base(c).connection
      add_system_tags(conn, schema, CUSTOM_TAGS, hidden: false)
    end
  end

  def down
    remove_system_tags(@db_template, 'galileo_template', CUSTOM_TAGS)
    # Next per customer
    Customer.all.each do |c|
      @log.info "Removing system tags/groups from #{c.customer_name}"
      schema     = c.customer_db_schema
      conn       = get_customer_base(c).connection
      remove_system_tags(conn, schema, CUSTOM_TAGS)
    end

    add_system_tags(@db_template, 'galileo_template', CUSTOM_TAGS_before, hidden: false)
    # Next per customer
    Customer.all.each do |c|
      @log.info "Adding system tags/groups to #{c.customer_name}"
      schema     = c.customer_db_schema
      conn       = get_customer_base(c).connection
      add_system_tags(conn, schema, CUSTOM_TAGS_before, hidden: false)
    end
  end


end
