#!/usr/local/bin/ruby

require 'awesome_print'
require 'ostruct'
require 'json'

class Props < OpenStruct

  def initialize(nodename:,storename:,credfile:,keyfile:)
    super()
    self.prop_nodename  = nodename
    self.prop_filename  = storename
    self.prop_credfile  = credfile 
    self.prop_keyfile   = keyfile
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
    cc = `gpecredentials get -k #{self.prop_keyfile} -c #{self.prop_credfile} > /dev/null 2>&1`
    return $?.success?
  end

  def get_credentials(get_if_not_found=true)
    if credentials_available?
      creds = `gpecredentials get -k #{self.prop_keyfile} -c #{self.prop_credfile}`
      self.username, self.password = creds.lines.map(&:chomp)
    else
      put_credentials if get_if_not_found
    end
    return self
  end

  def put_credentials
    system("gpecredentials put -k #{self.prop_keyfile} -c #{self.prop_credfile}")
    get_credentials
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

pp = Props.new(
   nodename: :gvoent1, 
  storename: '/tmp/gvoent1.service',
   credfile: '/tmp/gvoent1.cred',
    keyfile: '/tmp/password.key',
)

ap pp.get_credentials
