require 'fileutils'


class Environment

  # Create these directory locations
  HOME_DIRS = %w(bin etc lib log service tmp var var/files var/cache var/archive)

  attr_reader :home, :argv, :paths

  def initialize(argv: ARGV)
    @home  = set_home
    @argv  = argv
    @paths = make_structure
  end

  private

  def make_structure
    ret = OpenStruct.new
    HOME_DIRS.each do |dir|
      name = dir.gsub("/","_")
      path = [home, dir].join('/')
      FileUtils.mkdir_p(path)
      ret[name] = File.new(path)
    end
    return ret
  end

  def set_home
    return is_directory?(is_writable?(ENV['GPE_HOME']))
    raise "GPE_HOME is not set."
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
