require 'rubygems'
require 'jira-ruby'
require 'awesome_print'

options = {
  :username     => 'rdavis@galileosuite.com',
  :password     => 'bmc123!@#',
  :site         => 'http://galileosuite.atlassian.net:443',
  :context_path => '',
  :auth_type    => :basic
}

ap client = JIRA::Client.new(options)
exit
project = client.Project.find('MD')

project.issues.each do |issue|
  puts "#{issue.id} - #{issue.summary}"
end
