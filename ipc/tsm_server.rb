require 'awesome_print'

class TsmServer

  attr_reader :command

  def initialize(reader, admin: 'admin', password: 'admin')
    @command="dsmadmc -se=gem -id=#{admin} -pa=#{password} -display=list"
    ap popen
  end

  def exec(cmd:nil)
    return false if cmd.nil?
    result=system(@command + " " + cmd)
  end

end
