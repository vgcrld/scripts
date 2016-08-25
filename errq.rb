#!/usr/bin/env ruby

require 'awesome_print'


class GpeErrors

  attr_reader :report,
              :search_path

  def initialize( search = "/share/*01/process/*/tmp/ERROR*" )
    @search_path = search_path
    @report      = build( search_path )
  end

  def build( search )
    ret = {}
    Dir.glob("/share/*01/process/*/tmp/ERROR*").map do |file| 
      s          = file.split("/")
      env        = s[2].to_sym
      customer   = s[4]
      file       = s[6].split(".").values_at(1,2)
      uuid       = file[0]
      type       = file[1]
      # Build report
      ret[env]                 ||= {}
      ret[env][customer]       ||= {}
      ret[env][customer][type] ||= []
      ret[env][customer][type] << uuid
    end
    return ret
  end

  def environments
    @report.keys
  end

  def customers
    @report.map{ |env,cust| cust.keys }.flatten
  end

  def get( env = :all )
    return @report if env == :all
    return @report[env] unless @report[env].nil?
    return nil
  end

end


report = GpeErrors.new

ap report.get :prd01


