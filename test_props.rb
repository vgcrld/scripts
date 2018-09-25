require_relative './props.rb'

x = Props.new(
  nodename: :test_props,
  credfile: '/tmp/test_props.cred',
  keyfile: '/tmp/password.key',
  storename: '/tmp/test_props.json'
)

x.name = 'Richard Davis'
x.write


