#!/usr/local/bin/ruby

require 'awesome_print'
require 'ostruct'
require 'json'

class Props < OpenStruct

  CREDENTIALS_BINARY = "gpecredentials"

  def initialize(nodename:,storename:,credfile:,keyfile:)
    super()
    self.prop_nodename  = nodename
    self.prop_filename  = storename
    self.prop_credfile  = credfile 
    self.prop_keyfile   = keyfile
    yield(self) if block_given?
    load_props
  end

  def load_props
    if File.file?(self.prop_filename)
      file = File.read(self.prop_filename)
      JSON.parse(file).each_pair{ |k,v| self[k]=v }
    end
    return self
  end
  
  def credentials_available?
    cc = `#{CRED_BINARY} get -k #{self.prop_keyfile} -c #{self.prop_credfile} > /dev/null 2>&1`
    rc = $?
    if rc.exitstatus == 127
      raise "#{CRED_BINARY} executable was not found."
    end
    return $?.success?
  end

  def get_credentials(call_put_if_not_found=true)
    if credentials_available?
      creds = `#{CRED_BINARY} get -k #{self.prop_keyfile} -c #{self.prop_credfile}`
      self.username, self.password = creds.lines.map(&:chomp)
    else
      put_credentials if call_put_if_not_found
    end
    return self
  end

  def put_credentials
    system("#{CRED_BINARY} put -k #{self.prop_keyfile} -c #{self.prop_credfile}")
    get_credentials
  end

  def drop(field)
    self.delete_field(field) if self.to_h[field]
    self.write
  end

  def write
    props = File.open(self.prop_filename,'w+')
    data = self.to_h
    data.delete(:username)
    data.delete(:password)
    props.write(data.to_json)
    props.close
  end

end
