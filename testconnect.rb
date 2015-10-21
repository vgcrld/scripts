require 'rbvmomi'
require 'awesome_print'

vim = RbVmomi::VIM.connect host: 'nosprdvcapp01.ats.local', user: 'rdavis@ats.local', password: 'bmc123!@#', ssl: true, port: 443, insecure: true
dc = vim.serviceInstance.find_datacenter("Xand") or fail "datacenter not found"

ap dc
