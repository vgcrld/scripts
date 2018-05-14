require 'fileutils'

class Environment

  # Create these directory locations
  HOME_DIRS = %w(bin etc lib log service tmp var var/files var/cache var/archive)

  attr_reader :home, :args, :paths

  def initialize(args: ARGV)
    @home  = set_home
    @args  = args
    @paths = make_structure(@home,HOME_DIRS)
  end

  def dirs
    return @paths.to_h.keys
  end

  private

  def method_missing(m, *args)
    return @paths[m].path
  end

  def make_structure(home,dir_list)
    ret = OpenStruct.new
    dir_list.each do |dir|
      name = dir.gsub("/","_")
      path = [home, dir].join('/')
      FileUtils.mkdir_p(path)
      ret[name] = File.new(path)
    end
    return ret
  end

  def set_home
    raise "GPE_HOME is not set." unless ENV['GPE_HOME']
    return is_directory?(is_writable?(ENV['GPE_HOME']))
  end

  def env_set?(key)
    return ENV[key] ? true : false
  end

  def is_directory?(file)
    return file if File.directory?(file)
    raise "#{file} is not a directory."
  end

  def is_writable?(file)
    return file if File.writable?(file)
    raise "#{file} is not writable."
  end

end
