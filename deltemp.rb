
require 'awesome_print'

# @param glob [String] is a Dir.glob path specification for files to delete
# @param block [&block] selects the file to be deleted.
# @return [Integer] the total number of objects NOT deleted
def cleanup_dir(glob=nil)
  files = []
  Dir.glob(glob).each do |file|
    result = yield(file)
    files << result unless result.nil?
  end
  deleted = 0
  failed  = 0
  files.each do |file|
    begin 
      puts "Deleting: #{file}"
      File.unlink(file)
      deleted += 1
    rescue Exception => e
      failed += 1
      puts "Unable to delete: #{e.message}"
    end
  end
  if deleted > 0
    puts "Deleted #{deleted} file(s)"
  end
  return failed
end

# The block controls what get's deleted in the glob/path given.
# The resulting file is what ends up deleted.
x = cleanup_dir('/tmp/*') do |file|
  is_old  = ((Time.now.to_i - File.mtime(file).to_i) / (60*60*24)) > 1
  is_exec = File.executable?(file)
  is_file = File.file?(file)
  file if is_old and is_exec and is_file
end

puts x
