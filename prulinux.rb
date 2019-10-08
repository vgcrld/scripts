
require 'ap'

base="/share/prd01/process/Prudential/archive/by_name"


%w[ jphyb2ld45 car0031cy018 arbue2ld2 arbue1ld9 car0031ax030 car0031ax037 ].each do |file|
  full = "#{base}/#{file}/#{file}*.linux.gz"
  all  = Dir.glob(full)
  puts all.sort[-1]
end

