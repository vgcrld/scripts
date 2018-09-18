# item.rb

module Galileo

  class API

    private
    # Retrieve list of items of the given type(s).  For each item returned, the id, type and display name
    # is provided
    #
    # @param                     [optional,String,Array<String>] types           Types of items to return
    #
    # @return_hash result        [Hash]                  :data           Item information
    #
    # @return_hash result[:data] [Array<Integer>]        :items          Ordered list of item ids
    # @return_hash result[:data] [Array<String>]         :display_names  Ordered list of item display names
    # @return_hash result[:data] [Array<String>]         :types          Ordered list of item types
    #
    # @example Default item list
    #
    #   api.item_list
    #     => {
    #          :code     => 0,
    #          :method   => :item_list,
    #          :data     => {
    #            :items         => [
    #              15,
    #              9
    #            ],
    #            :display_names => [
    #              "10129Z1 (9117-MMA)",
    #              "10129Z1 (7028-6E1)"
    #            ],
    #            :types         => [
    #              "frame",
    #              "frame"
    #            ]
    #          }
    #        }
    #
    # @example Item list of frames and hosts
    #
    #   api.item_list ["frame","host"]
    #     => {
    #          :code     => 0,
    #          :method   => :item_list,
    #          :data     => {
    #            :items         => [
    #              15,
    #              9,
    #              221,
    #              19,
    #              55
    #            ],
    #            :display_names => [
    #              "10129Z1 (9117-MMA)",
    #              "10129Z1 (7028-6E1)",
    #              "aixhost1",
    #              "aixhost2",
    #              "aixhost3",
    #            ],
    #            :types         => [
    #              "frame",
    #              "frame",
    #              "host",
    #              "host",
    #              "host"
    #            ]
    #          }
    #        }
    #
    def __api_item_list(types="frame", item_ids=nil)
      items = @customer_models[:item].list(types, item_ids)
      item_ids             = Array.new
      item_display_names   = Array.new
      item_type_names      = Array.new
      items.each do |item|
        item_display_names.push  item.display_name
        item_type_names.push     item.type_name
        item_ids.push            item.item_id
      end
      success( :items => item_ids, :types => item_type_names, :display_names => item_display_names )
    end

    def __api_item_display_name(item_id, local_ts=nil, timezone="UTC")
      display_name = @customer_models[:item].find(item_id).display_name(local_ts, timezone)
      success( display_name )
    end

    # Return the list of children for a given item_id
    #
    # @param [Integer] item_id   Item ID to retrieve children for
    # @param [Array]   types     Item types to limit children to
    # @param [Array]   tags      Item tags  to limit children to
    # @param [String]  start_ts  Start of time range
    # @param [String]  end_ts    Start of time range
    #
    # @return_hash result [Hash] :data Child information
    #
    # @return_hash result[:data] [Array<Integer>]        :items          Ordered list of item ids
    # @return_hash result[:data] [Array<String>]         :display_names  Ordered list of item display names
    # @return_hash result[:data] [Array<String>]         :types          Ordered list of item types
    #
    # @example Children of frame
    #
    #   api.item_children 1, "host"
    #     => {
    #          :code     => 0,
    #          :method   => :item_children,
    #          :data     => {
    #            :items         => [
    #              244,
    #              2
    #            ],
    #            :display_names => [
    #              "aixchildhost1",
    #              "aixchildhost2"
    #            ],
    #            :types         => [
    #              "host",
    #              "host"
    #            ]
    #          }
    #        }
    #
    def __api_item_children(item_id,types=nil,tags=nil,range=nil)
      items = @customer_models[:item].find(item_id).children(types,tags,range)
      item_ids             = Array.new
      item_display_names   = Array.new
      item_type_names      = Array.new
      items.each do |item|
        item_display_names.push  item.display_name
        item_type_names.push     item.type_name
        item_ids.push            item.item_id
      end
      success( :items => item_ids, :types => item_type_names, :display_names => item_display_names )
    end

    # Return item information
    #
    # @param [Integer]          item_id  Item ID of the object to be queried
    # @param [optional,String]  ts       Timestamp for request (may affect the name)
    #
    # @return_hash result [Hash] :data Item info
    #
    # @return_hash result[:data] [String] :type        Item type name
    # @return_hash result[:data] [String] :name        Item name
    # @return_hash result[:data] [String] :alias       Item alias name
    # @return_hash result[:data] [Hash]   :type_info   Type-specific info {Galileo::API#item_type_info}
    #
    # @example Information for an adapter
    #
    #   api.item_info 3
    #     => {
    #          :code     => 0,
    #          :method   => :item_info,
    #          :data     => {
    #            :name         => "mickey",
    #            :type         => "host",
    #            :tag_type     => "OS"
    #          }
    #        }
    #
    def __api_item_info(item_id, opt={})
      begin
        success @customer_models[:item].find(item_id).info( opt )
      rescue ActiveRecord::RecordNotFound => error
        failure i18n("api.object.error.not_found")
      rescue => error
        failure error.message
      end
    end

    # Return item type information
    #
    # @param                     [String]        item_type     Item Type to be queried (i.e., host, disk, etc)
    #
    # @return_hash result        [Hash]          :data         Type information
    #
    # @return_hash result[:data] [Array<String>] :attributes   Attribute names
    #
    # @example Type info for "disk"
    #
    #   api.item_type_info "disk"
    #     => {
    #          :code     => 0,
    #          :method   => :item_type_info,
    #          :data     => {
    #            :attributes"  => [
    #              "DiskBsize",
    #              "DiskRead",
    #              "DiskServ",
    #              "DiskWrite",
    #              "DiskXfer"
    #            ]
    #          }
    #        }
    #
    def __api_item_type_info(item_type="host")
      results              = Hash.new
      results[:attributes] = @master_models["template_load_#{item_type}".to_sym].attributes
      success( results )
    end

    # Return the list of known item (object) types
    #
    # @return_hash result        [Array<String>]          :data         Known item types
    #
    # @example List types
    #
    #   api.item_types
    #     => {
    #          :code     => 0,
    #          :method   => :item_types,
    #          :data     => [
    #            "adapter",
    #            "cpu",
    #            "disk",
    #            "frame",
    #            "fs",
    #            "host",
    #            "net",
    #            "tape"
    #          ]
    #        }
    #
    def __api_item_types
      types = Array.new
      @master_models.keys.each do |model|
        types.push($1) if model.to_s =~ /^template_load_(.*)/
      end
      success( types.sort )
    end

    # Delete specified item
    #
    # @param [Integer] item_id ID of item to delete
    def __api_item_delete(item_id)
    end

    def __api_item_summary_level( *params )
      success @customer_models[:item].summary_level_by_samples( *params )
    end

    # Retrieve the current alias for the given item
    #
    # @param                     [Integer] item           Item to return alias for
    #
    # @return_hash  result        [String]                  :data           Item alias
    #
    # @example Item alias for item 1
    #
    #   api.get_item_alias [1]
    #     => {
    #          :code     => 0,
    #          :method   => :get_item_alias,
    #          :data     => "development"
    #        }
    #
    def __api_get_item_alias(item_id)
      unless item_id.nil?
        item = @customer_models[:item].find_by_item_id(item_id)
        return failure( i18n('api.item.error.not_found') ) if item.nil?
        alias_rec = item.aliases.find_by_item_id(item_id)
        if alias_rec.nil?
          success(nil)
        else
        success( alias_rec.item_alias)
        end
      else
        failure(i18n('api.error.argument.invalid', :args=> "item_id"));
      end
    end

    # Set the current alias for the given item
    #
    # @param                       [Integer] item                   Item to set alias for
    # @param                       [String]  item_alias             Alias
    #
    # @return_hash  result         [String]  :data                  result
    # @return_hash  old_item_alias [String]  :data[:old_item_alias] The alias formerly assigned to this item
    # @return_hash  item_alias     [String]  :data[:item_alias]     The newly assigned alias
    #
    # @example Set item alias for item 1
    #
    #   api.set_item_alias [1, "new alias"]
    #     => {
    #          :code     => 0,
    #          :method => "set_item_alias",
    #          :data => {
    #                     :old_item_alias":"alias",
    #                     :item_alias":"alias"
    #                   }
    #
    #        }
    #
    def __api_set_item_alias(item_id, item_alias)
      invalid_params = { "item_id" => item_id.nil?,
                 "item_alias" => item_alias.nil? }.delete_if { |k,v| !v }
      new_item_alias = item_alias.strip! || item_alias
      unless !invalid_params.empty?
        old_alias = nil
        item = @customer_models[:item].find_by_item_id(item_id)

        return failure( i18n('api.item.error.not_found')) if item.nil?

        alias_rec = item.aliases.find_by_item_id(item_id)
        unless alias_rec.nil?
          if new_item_alias == "" then
             #not sure I like this, may violate POLS
             alias_rec.destroy
             new_item_alias = nil
          else
            old_alias = alias_rec.item_alias
            alias_rec.user_id = @auth_user.user_id
            alias_rec.item_alias = new_item_alias
            alias_rec.save
          end
        else
          unless new_item_alias == ""
            item.aliases.create({:user_id => @auth_user.user_id, :item_alias => new_item_alias})
          else
            new_item_alias = nil
          end
        end
        success ({:old_item_alias => old_alias, :item_alias => new_item_alias, :item_name => item.display_name })
      else
        return failure( i18n('api.error.argument.invalid',
                             :args => invalid_params.keys.join(", ") ))
      end

    end

    def process_aggs(trends, poll_epoch)
      result = Hash.new

      trends.each do |trend|
        item_id = trend["item_id"]
        trend.each do |met, val|
          next if met == "item_id"

          name    = "agg_#{met}"
          result[item_id] ||= Hash.new
          result[item_id][name] = {
            :name    => name,
            :value   => val.to_f,
            :period  => poll_epoch
          }
        end
      end
      return result
    end

    def process_trends(trends, prefix="trend")
      result = Hash.new

      trends[:data].each do |trend_key, trend_values|
        trend_name, trend_item_id = trend_key.match(/^(.*)_(\d+)$/).captures
        name    = "trend_#{trend_name}"
        result[trend_item_id] ||= Hash.new
        result[trend_item_id][name] = {
          :name    => name,
          :value   => trend_values.last,
          :period  => trends[:periods].last
        }
      end
      return result
    end

    def process_union_trends(trends, name_map)
      result = Hash.new

      trends.each do |trend|
        item_id = trend["item_id"]
        trend.each do |key, val|
          next if key == 'item_id' or val.nil? or key =~ /_poll_epoch$/
          poll_epoch  = trend["#{key}_poll_epoch"].to_i
          name        = name_map[key]
          result[item_id] ||= Hash.new
          if result[item_id][name].nil? 
            result[item_id][name] = {
              :name    => name,
              :value   => val.to_f,
              :period  => poll_epoch,
              :changed  => false
            }
          elsif result[item_id][name][:period] < poll_epoch
            result[item_id][name][:value] = val.to_f
            result[item_id][name][:changed] = true
          else
            result[item_id][name][:changed] = true
          end
        end
      end

      return result
    end

    def process_configs(configs, prefixes=['config_'])
      result  = Hash.new

      configs.each do |config|
        next if config.poll_epoch.nil? or config.config_value.nil?
        prefixes.each do |prefix|
          name  = "#{prefix}#{config.config.config_name}"
          if result[config.item_id.to_s].nil? or result[config.item_id.to_s][name].nil?
            result[config.item_id.to_s]  ||= Hash.new
            result[config.item_id.to_s][name] = {
              :name    => name,
              :value   => config.config_value,
              :changed => false
            }
          else
            result[config.item_id.to_s][name] = {
              :name    => name,
              :value   => config.config_value,
              :changed => true
            }
          end
        end
      end

      return result
    end

    def __api_item_last_data(item_id, range=nil, attributes=[])
      invalid_params = { "item_id" => item_id.nil? }.delete_if { |k,v| !v }
      return failure( i18n('api.error.argument.invalid', :args => invalid_params.keys.join(", ") )) unless invalid_params.empty?

      item    = @customer_models[:item].find_by_item_id(item_id)
      return failure( i18n('api.item.error.not_found') ) if item.nil?

      # Determine range representing last poll period
      range_last = get_last_range(item,range)
      return success({}) if range_last.nil?

      # Get lowest summary level
      summary = item.summary_level_by_samples(1,range_last)

      result = get_last_data([item], attributes, range, range_last, :summary => summary).values.first

      return success({:order=>attributes, :data=>result})

    end

    def __api_item_last_data_children(item_id, range=nil, types=nil, tags=nil, attributes=[], opt={})
      invalid_params = { "item_id" => item_id.nil? }.delete_if { |k,v| !v }
      return failure( i18n('api.error.argument.invalid', :args => invalid_params.keys.join(", ") )) unless invalid_params.empty?

      # Find item
      item     = @customer_models[:item].find_by_item_id(item_id)
      return failure( i18n('api.item.error.not_found') ) if item.nil?


      # Determine range representing last poll period
      range_last = range.clone
      range_last = get_last_range(item,range) unless range_last.nil?

      unless range.nil? or range[:range_type].nil? or range[:range_type] == "custom"
        range_last[:range_type] = range[:range_type].to_sym
      end
      # return success({}) if range_last.nil?

      # Get lowest summary level
      summary = nil
      summary = item.summary_level_by_samples(1,range_last) unless range_last.nil?

      # Find active children
      children = item.children(types, tags, range_last, opt)

      # Retrieve combined (config + trend) data
      result = get_last_data(children, attributes, range, range_last, :summary => summary)

      return success(result);
    end

    def __api_items_last_data(item_ids=nil, range=nil, types=nil, tags=nil, attributes=[], opt={})
      selectors = Array.new
      unless types.nil?
        selectors << Galileo::DB::Alert::Selector::Type.new([*types])
      end
      unless tags.nil?
        selectors << Galileo::DB::Alert::Selector::Tag.new([*tags])
      end

      unless selectors.empty?
        # item_ids = Galileo::DB::Alert::Selector::And.new(selectors).select(@db.customer[:models], nil, item_ids)
        item_ids = Galileo::DB::Alert::Selector::And.new(selectors).select(@db.customer[:models], nil, nil, {:cache => false, :single_use => true})
      end

      result = get_last_data(item_ids, attributes, range, range, opt)

      return success(result)
    end

    def limit_selector(selector, opts)

      ret = selector

			if !opts[:limit_by].nil?
				limits	= opts[:limit_by]
				if !limits[:vframe_id].nil?
					vframe_sel    = Galileo::DB::Alert::Selector::VFrame.new([limits[:vframe_id]].flatten)
					vframe_ch_sel = Galileo::DB::Alert::Selector::ChildrenByParentVFrame.new([limits[:vframe_id]].flatten)

					ret = Galileo::DB::Alert::Selector::And.new([Galileo::DB::Alert::Selector::And.new([vframe_sel, vframe_ch_sel]), selector])
				end

				if !limits[:tag].nil?
					tag_sel    = Galileo::DB::Alert::Selector::CustomTag.new([limits[:tag]])
					tag_rel_sel = Galileo::DB::Alert::Selector::RelativeByCustomTag.new([limits[:tag]])
          tag_sel.time_range_limit = selector.time_range_limit
          tag_rel_sel.time_range_limit = selector.time_range_limit
					ret = Galileo::DB::Alert::Selector::And.new([Galileo::DB::Alert::Selector::Or.new([tag_sel, tag_rel_sel]), selector])
				end
        ret.time_range_limit = selector.time_range_limit
			end

      return ret
    end

    def __api_item_ids_from_selector(selector_hash, range=nil, opt={})
      selector  = Galileo::DB::Alert::Selector.unmarshal_selector_hash(selector_hash)

      if !range.nil? and range[:range_type].nil?
        range[:range_type] ='last_1440'
      end

      selector  = limit_selector(selector, opt)

      item_ids  = selector.select(@db.customer[:models], nil, range, {:cache => false, :single_use => true})
      # item_ids  = selector.select(@db.customer[:models], nil, range)

      return success(:total_count => item_ids.length, :item_ids => item_ids)
    end

    def __api_item_count_from_selector(selector_hash, range=nil, opt={})
      selector  = Galileo::DB::Alert::Selector.unmarshal_selector_hash(selector_hash)

      if !range.nil? and range[:range_type].nil?
        range[:range_type] ='last_1440'
      end

      item_ids  = selector.select(@db.customer[:models], nil, range, {:cache => false, :single_use => true})
      # item_ids  = selector.select(@db.customer[:models], nil, range)

      return success(:count => item_ids.length)
    end

    def __api_items_last_data_from_selector(selector_hash, range=nil, attributes=[], opt={})
      selector  = Galileo::DB::Alert::Selector.unmarshal_selector_hash(selector_hash)

      selector  = limit_selector(selector, opt)

      if !range.nil? and range[:range_type].nil?
        range[:range_type] ='last_1440'
      end

      item_ids  = selector.select(@db.customer[:models], nil, range, {:cache => false, :single_use => true})
      # item_ids  = selector.select(@db.customer[:models], nil, range)
      return success([]) if item_ids.empty?

      item      = @db.customer[:models][:item].find(item_ids.first)

      # Get lowest summary level
      summary = nil
      if range.nil?
        summary = item.minimum_summary_level(range)
      else
        summary = item.summary_level_by_samples(1,range)
      end


      result = get_last_data(item_ids, attributes, range, range, :summary => summary)

      return success(result)
    end

    def get_last_range(item,range)
      # Determine last poll epoch
      last_poll_epoch =  item.find_latest_ts(range)
      return nil if last_poll_epoch.nil?
      range_last = {
        :utc_ts     => Time.at(last_poll_epoch),
        :range_type => :last_10
      }
    end

    def parse_out_key(full)
      key, rest = full.split("_", 2)

      if key == "netapp"
        key   = full.split("_")[0..2].join('_')
        rest  = full.split("_")[3..-1].join('_')
      elsif key == "brocade"
        key   = full.split("_")[0..1].join('_')
        rest  = full.split("_")[2..-1].join('_')
      elsif key == "cisco"
        key   = full.split("_")[0..2].join('_')
        rest  = full.split("_")[3..-1].join('_')
      elsif key == "ibmi"
        key   = full.split("_")[0..1].join('_')
        rest  = full.split("_")[2..-1].join('_')
      end

      return key, rest
    end

    def get_last_data(items, attributes, range_full, range_last, opt={})

      # Initialize result hash
      result = Hash.new{ |h,k| h[k] = Hash.new }

      # Separate config and trend attributes
      names = {:config => [], :trend => [], :agg => [], :parentconfig => [], :typedtrend => [], :typedagg => [], :customtag=>[], :chart=>[], :itemdata=>[]}
      attributes.each do |attribute|
        type,name = attribute.split('_',2)
        names[type.to_sym].push name
      end

      # Get config values
      unless names[:config].empty?
        configs = @customer_models[:item].config_for_range_raw(items, names[:config], range_full)
        configs_result = process_configs(configs)
        configs_result.each{ |item_id,vals| result[item_id].merge!( vals ) }
      end

      # Expose items columns and values derived from items
      unless names[:itemdata].empty?
        get_values = names[:itemdata]
        itemdata = @customer_models[:item].find(:all, :conditions => ["item_id in (?)", items])
        itemdata.each do |item|
          id = item.item_id
          get_values.each do |column|
            key = "itemdata_#{column}"
            case column
            when "last_access_days"
              result[id.to_s].merge!({
                key.to_sym => {
                  :name => key,
                  :value => ((Time.now.to_i - item.last_epoch).to_f / (24*60*60)),
                  :changed => false
                }
              })
            else
              result[id.to_s].merge!({
                key.to_sym => {
                  :name => key,
                  :value => item[column],
                  :changed => false
                }
              })
            end
          end
        end
      end

      unless names[:customtag].empty?
        custom_tags = @customer_models[:custom_tag].get_tags_for_items(items)
        custom_tags.each do |item_id, tags|
          result[item_id.to_s].merge!({
            "customtag_#{names[:customtag].first}" => {
              :name    => "customtag",
              :changed => false,
              :value   => tags.map{|t| [t[:group], t[:tag]].compact.join(':')}.uniq.join("$$")
            }
          })
        end
      end

      unless names[:chart].empty?
        chart_info  = fetch_chart_info_for_items(items, names[:chart])
        names[:chart].each do |name|
          chart_names = chart_info.keys.select{|k| k =~ /#{name}/}
          chart_names.each do |chart_name|
            infos  = chart_info[chart_name]
            infos.each do |info|
              if !result[info[:item_id].to_s].nil? and !result[info[:item_id].to_s]["chart_#{name}"].nil?
                result[info[:item_id].to_s]["chart_#{name}"][:value] += "&#{info[:chart_id]}:#{info[:chart_name]}"
              else
                result[info[:item_id].to_s].merge!({
                  "chart_#{name}" => {
                    :name    => "chart_#{name}",
                    :changed => false,
                    :value   => "#{info[:chart_id]}:#{info[:chart_name]}"
                  }
                })
              end
            end
          end
        end
      end

      # Get parents config values
      unless names[:parentconfig].empty?
        start_local_ts,end_local_ts,timezone=Galileo::DB.calculate_range(range_last)
        ts_start = Galileo::DB.local_ts_to_utc(start_local_ts,timezone).to_i
        ts_end   = Galileo::DB.local_ts_to_utc(end_local_ts,timezone).to_i

        if range_last.nil?
          ts_start  = ts_end - 60*60*24
        end

        parent_configs  = Hash.new
        names[:parentconfig].each do |config|
          src_type, rest        = parse_out_key(config)
          agg_type, config_name = parse_out_key(rest)

          key = "#{src_type}_#{agg_type}"
          parent_configs[key]  ||= {
            :src_type => src_type,
            :agg_type => agg_type,
            :configs  => Set.new
          }
          parent_configs[key][:configs] << config_name
        end
        src_types = parent_configs.values.map { |v| v[:src_type] }
        agg_types = parent_configs.values.map { |v| v[:agg_type] }
        config_names = parent_configs.values.map { |v| v[:configs].to_a }.flatten.uniq

        rel = @customer_models[:trend_relationship].from_by_name(src_types, agg_types)
        parent_column_names = rel.map{|r| r.aggregate_column} unless rel.nil?
        src_types = rel.map{|r| r.item_type} unless rel.nil?

        cache_table = @customer_models[:item].create_temporary_table("item_id INT", data: "VALUES #{items.map{|i| "(#{i})"}.join(", ")}")

        master_ids, master_map, item_ids = @customer_models[:item].get_parent_ids(items, src_types, parent_column_names, cache_table, ts_start, ts_end)

        # tbl = @customer_models[:item].parents_through_trend_relationship(table: cache_table, ts_start: ts_start, ts_end: ts_end, allow_timerange_ignore: true)
        tbl = @customer_models[:item].parents_through_trend_relationship(table: cache_table, allow_timerange_ignore: true, types_limit: agg_types)

        mapping = tbl.values_array
        master_map  = Hash.new
        mapping.each do |map|
          master_map[map[0].to_i] ||= Array.new
          master_map[map[0].to_i] << map[1].to_i
        end

        configs = @customer_models[:item].config_for_range_raw(master_map.keys, config_names, range_full)
        configs_result = process_configs(configs, parent_configs.keys.map{|k| "parentconfig_#{k}_"})

        configs_result.each do |item_id,vals| 
          id  = item_id.to_i
          next if master_map[id].nil?
          master_map[id].each do |i|
            result[i.to_s].merge!( vals ) 
          end
        end
      end

      # Get trend values
      unless names[:trend].empty?
        start_local_ts,end_local_ts,timezone=Galileo::DB.calculate_range(range_last)
        trend_range = {
          :range_type => "last_5",
          :utc_ts => end_local_ts
        }
        trend_summary = 300
        trends = @customer_models[:item].trend(items, names[:trend], trend_range, :summary => trend_summary, :passthrough => true)
        trends_result = process_trends(trends)
        trends_result.each{ |item_id,vals| result[item_id].merge!( vals ) }
      end

      # Get typed trend values
      unless names[:typedtrend].empty?
        trend_reqs = Hash.new
        inner_name = 'trend'

        name_map   = Hash.new
        names[:typedtrend].each_with_index do |req, index|
          name  = "trend_att_#{index}"
          type, formula = req.split("_", 2)
          if type == "netapp"
            type = req.split("_")[0..2].join('_')
            formula = req.split("_")[3..-1].join('_')
          elsif type == "brocade"
            type = req.split("_")[0..1].join('_')
            formula = req.split("_")[2..-1].join('_')
          elsif type == "cisco"
            type = req.split("_")[0..2].join('_')
            formula = req.split("_")[3..-1].join('_')
          elsif type == "ibmi"
            type = req.split("_")[0..1].join('_')
            formula = req.split("_")[2..-1].join('_')
          end
          name_map[name] = "typedtrend_#{req}"
          trend_reqs[type] ||= Array.new
          trend_reqs[type] << {:type => type, :formula => formula, :name => name}
        end
        selectors      = Hash.new
        group_by       = ["item_id"]
        outer_selector = ["#{inner_name}.item_id"]
        nulled_select  = ['item_id']

        trend_reqs.each do |type, trends|
          trends.each do |trend|
            outer_selector << "#{inner_name}.#{trend[:name]}"
            outer_selector << "#{inner_name}.#{trend[:name]}_poll_epoch"
            group_by << trend[:name]
            if selectors[type].nil?
              selectors[type] = Array.new
              selectors[type] += nulled_select
            end
            nulled_select << "NULL as #{trend[:name]}"
            nulled_select << "NULL as #{trend[:name]}_poll_epoch"
            selectors.each do |sel_type, sel|
              if sel_type == type
                sel << "#{trend[:formula]} as #{trend[:name]}"
                sel << "MIN(poll_epoch) as #{trend[:name]}_poll_epoch"
              else
                sel << "NULL as #{trend[:name]}"
                sel << "NULL as #{trend[:name]}_poll_epoch"
              end
            end
          end
        end

        if items.first.is_a? Integer
          cache_table = @customer_models[:item].create_temporary_table("item_id INT", data: "VALUES #{items.map{|i| "(#{i})"}.join(", ")}")
        else
          cache_table = @customer_models[:item].create_temporary_table("item_id INT", data: "VALUES #{items.map{|i| "(#{i.item_id})"}.join(", ")}")
        end

        start_local_ts,end_local_ts,timezone=Galileo::DB.calculate_range(range_last)
        ts_start = Galileo::DB.local_ts_to_utc(start_local_ts,timezone).to_i
        ts_end   = Galileo::DB.local_ts_to_utc(end_local_ts,timezone).to_i

        inner_where  = ["poll_epoch >= #{ts_start}", "poll_epoch <= #{ts_end}"]


        trend_parms = {
          :outer_select   => outer_selector,
          :inner_select   => selectors,
          :inner_name     => inner_name,
          :inner_where    => inner_where,
          :inner_group_by => group_by,
          :outer_join     => ["#{cache_table.full_name} ON (#{inner_name}.item_id = #{cache_table.full_name}.item_id)"],
        }

        recs = @customer_models[:item].trend_union_query(items, trend_parms)

        trends_result = process_union_trends(recs, name_map)
        trends_result.each{ |item_id,vals| result[item_id].merge!( vals ) }
      end

      # Get typed agg values
      unless names[:typedagg].empty?
        trend_reqs = Hash.new
        inner_name = 'trend'

        name_map   = Hash.new
        names[:typedagg].each_with_index do |req, index|
          name     = "agg_att_#{index}"
          reqs     = req.split("_")
          hours    = reqs[0]
          agg_func = reqs[1]
          type     = reqs[2]
          formula  = reqs[3..-1].join('_')
          if type == "netapp"
            type = req.split("_")[2..4].join('_')
            formula = req.split("_")[5..-1].join('_')
          elsif type == "brocade"
            type = req.split("_")[2..3].join('_')
            formula = req.split("_")[4..-1].join('_')
          elsif type == "cisco"
            type = req.split("_")[2..4].join('_')
            formula = req.split("_")[5..-1].join('_')
          elsif type == "ibmi"
            type = req.split("_")[2..3].join('_')
            formula = req.split("_")[4..-1].join('_')
          elsif req =~ /vmwareguest_datastore/
            type = req.split("_")[2..3].join('_')
            formula = req.split("_")[4..-1].join('_')
          end

          name_map[name] = "typedagg_#{req}"
          key = "#{hours}_#{agg_func}_#{type}"
          trend_reqs[key] ||= Array.new
          trend_reqs[key] << {:hours => hours, :agg_func => agg_func, :type => type, :formula => formula, :name => name}
        end

        start_local_ts,end_local_ts,timezone=Galileo::DB.calculate_range(range_last)
        ts_start = Galileo::DB.local_ts_to_utc(start_local_ts,timezone).to_i
        ts_end   = Galileo::DB.local_ts_to_utc(end_local_ts,timezone).to_i

        selectors      = Hash.new
        group_by       = ["item_id"]
        outer_selector = ["#{inner_name}.item_id"]
        nulled_select  = ['item_id']

        inner_where    = Hash.new

        trend_reqs.each do |key, trends|
          trends.each do |trend|
            outer_selector << "#{inner_name}.#{trend[:name]}"
            outer_selector << "#{inner_name}.#{trend[:name]}_poll_epoch"
            if selectors[key].nil?
              selectors[key] = { :type => trend[:type], :selectors => Array.new}
              selectors[key][:selectors] += nulled_select
              delta = trend[:hours].to_i * 60 * 60
              inner_where[key]  = ["poll_epoch >= #{ts_end - delta}", "poll_epoch <= #{ts_end}"]
            end
            nulled_select << "NULL as #{trend[:name]}"
            nulled_select << "NULL as #{trend[:name]}_poll_epoch"
            selectors.each do |sel_key, sel|
              if sel_key == key
                sel[:selectors] << "#{trend[:agg_func]}(#{trend[:formula]}) as #{trend[:name]}"
                sel[:selectors] << "MIN(poll_epoch) as #{trend[:name]}_poll_epoch"
              else
                sel[:selectors] << "NULL as #{trend[:name]}"
                sel[:selectors] << "NULL as #{trend[:name]}_poll_epoch"
              end
            end
          end
        end

        if items.first.is_a? Integer
          cache_table = @customer_models[:item].create_temporary_table("item_id INT", data: "VALUES #{items.map{|i| "(#{i})"}.join(", ")}")
        else
          cache_table = @customer_models[:item].create_temporary_table("item_id INT", data: "VALUES #{items.map{|i| "(#{i.item_id})"}.join(", ")}")
        end

        # inner_where  = ["poll_epoch >= #{ts_start}", "poll_epoch <= #{ts_end}"]


        trend_parms = {
          :outer_select   => outer_selector,
          :inner_select   => selectors,
          :inner_name     => inner_name,
          :inner_where    => inner_where,
          :inner_group_by => group_by,
          :outer_join     => ["#{cache_table.full_name} ON (#{inner_name}.item_id = #{cache_table.full_name}.item_id)"],
        }

        recs = @customer_models[:item].trend_union_query(items, trend_parms)

        trends_result = process_union_trends(recs, name_map)
        trends_result.each{ |item_id,vals| result[item_id].merge!( vals ) }
      end

      # Get trend values
      unless names[:agg].empty?
        start_local_ts,end_local_ts,timezone=Galileo::DB.calculate_range(range_last)
        end_utc         = Galileo::DB.local_ts_to_utc(end_local_ts,   timezone).to_s

        length             = names[:agg].map{|n| n.split("_").first.to_i}.max
        range              = range_last.clone
        range[:range_type] = "last_#{length*60}".to_sym
        range[:utc_ts]     = end_utc

        start_local_ts,end_local_ts,timezone=Galileo::DB.calculate_range(range)
        start_epoch       = Galileo::DB.local_ts_to_utc(start_local_ts, timezone).to_i
        end_epoch         = Galileo::DB.local_ts_to_utc(end_local_ts,   timezone).to_i

        trends = @customer_models[:item].agg_trend(items, names[:agg], range, :summary => opt[:summary])
        trends_result = process_aggs(trends, end_epoch)
        trends_result.each{ |item_id,vals| result[item_id].merge!( vals ) }
      end

      return result
    end

    def __api_item_last_timestamp(item_id, range=nil, attributes=[])
      invalid_params = { "item_id" => item_id.nil? }.delete_if { |k,v| !v }
      return failure( i18n('api.error.argument.invalid', :args => invalid_params.keys.join(", ") )) unless invalid_params.empty?

      item    = @customer_models[:item].find_by_item_id(item_id)
      return failure( i18n('api.item.error.not_found') ) if item.nil?

      # Determine last poll epoch
      last_poll_epoch =  item.find_latest_ts(range)
      return success({}) if last_poll_epoch.nil?

      return success(last_poll_epoch)

    end

    def __api_item_children_last_timestamp(item_id, range=nil, types=nil, tags=nil, opt={})
      invalid_params = { "item_id" => item_id.nil? }.delete_if { |k,v| !v }
      return failure( i18n('api.error.argument.invalid', :args => invalid_params.keys.join(", ") )) unless invalid_params.empty?

      # Find item
      item     = @customer_models[:item].find_by_item_id(item_id)
      return failure( i18n('api.item.error.not_found') ) if item.nil?

      # Determine range representing last poll period
      range_last = range
      range_last = get_last_range(item,range) unless range.nil?

      # Find active children
      children = item.children(types, tags, range_last, opt)

      result = @customer_models[:item].find_latest_ts(children, range_last)

      return success(result);
    end

    def fetch_chart_info_for_items(item_ids, chart_names)
      schema = @customer_models[:item].schema
      master = @customer_models[:item_type].schema

      names = chart_names.map{|c| "#{master}.charts.chart_name LIKE '%#{c}%'"}

      query =  "SELECT #{schema}.tag_objects.object_id, charts.chart_id, charts.chart_name\n"
      query += "  FROM #{schema}.tag_objects, #{schema}.tags, #{master}.tag_objects, #{master}.tags, #{master}.charts\n"
      query += "  WHERE #{schema}.tag_objects.tag_id = #{schema}.tags.tag_id AND #{schema}.tag_objects.object_id IN (#{item_ids.join(', ')})\n"
      query += "    AND #{master}.tags.tag_id = #{master}.tag_objects.tag_id AND #{master}.tags.tag_name = #{schema}.tags.tag_name AND #{master}.charts.chart_id = #{master}.tag_objects.object_id\n"
      query += "    AND (#{names.join(' OR ')})"

      result  = @customer_models[:item].connection.select_rows(query)

      ret = Hash.new
      result.each do |r|
        ret[r[2]] ||= Array.new
        ret[r[2]] << {
          :item_id    => r[0],
          :chart_id   => r[1],
          :chart_name => r[2]
        }
      end

      return ret
    end


  end

end
