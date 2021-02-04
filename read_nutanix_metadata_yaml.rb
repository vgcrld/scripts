
require 'awesome_print'
require 'yaml'

# Expects yaml in ARGF
yaml = YAML.load(ARGF)

ret = {} 
yaml.each do |d|    
    name = d['name'].split('.',2).first
    delta = d['interval'] - d['real-interval']
    ret[name] ||= []
    ret[name] << delta
end

ap ret