require 'aws-sdk'
require 'ap'

# 
# EC2
# 
#ec2 = Aws::EC2::Client.new(region: 'us-east-1')
#ap ec2.describe_instances


cloudwatch = Aws::CloudWatch::Client.new(region: 'us-east-1')
#ap cloudwatch.operation_names
ap cloudwatch.list_metrics.metrics.first

exit
# 
# S3
# 
s3 = Aws::S3::Resource.new(region: 'us-east-1')

my_bucket = s3.bucket('gitlab-backup.galileosuite.com')

my_bucket.objects.limit(50).each do |o|
  ap o.key
end
