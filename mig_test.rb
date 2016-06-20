#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] ||= "#{ENV['HOME']}/src/gpe-server/Gemfile"

#
# Sample rb - simple startup
#
require 'rubygems'
require 'bundler/setup'
require 'awesome_print'
require 'galileo_db'
require 'galileo_tasks/galileo_migration'

class UpdateVmwareMisSpell02082016 < GalileoTasks::Migration

  class Metric   < ActiveRecord::Base; set_primary_key :metric_id;    end
  class ItemType < ActiveRecord::Base; set_primary_key :item_type_id; end

  def up

    metrics = [
      [ 'VMCLUSTERmemSwapusedAverageGB', 'vmwarecluster', 'Swapped' ],
      [ 'VMGUESTmemSwappedAverageGB',    'vmwareguest',   'Swapped' ],
      [ 'VMHOSTmemSwapusedAverageGB',    'vmwarehost',    'Swapped' ],
    ]

    metrics.each do |metric|
      name = metric[0]
      type = ItemType.find_by_item_type_name(metric[1]).item_type_id
      desc = metric[2]
      update_metric( name, type, desc)
    end

  end

  def down
  end

  def update_metric( name, type, desc )
    @log.debug("Updating metric description for type #{type}: <#{name}:#{desc}>")
    metric = Metric.find_by_metric_name_and_item_type_id( name, type )
    metric.metric_desc = desc
    metric.save
  end

end

tasks = UpdateVmwareMisSpell02082016.new

tasks.up
