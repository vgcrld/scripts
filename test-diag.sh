
_gpe_agent_name=gpe-agent-vmware
_gpe_dir=$(cd $(dirname $0)/..; pwd)
_lib_dir="${_gpe_dir}/lib/${_gpe_agent_name}"

#Setup the Ruby Environment
BUNDLE_GEMFILE=${_lib_dir}/vendor/Gemfile
export BUNDLE_GEMFILE

PATH=${_lib_dir}/ruby/bin:$PATH
export PATH

"${_lib_dir}/app/${_gpe_agent_name}.rb" $*
