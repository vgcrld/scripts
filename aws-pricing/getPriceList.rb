require 'aws-sdk-pricing'
require 'awesome_print'
require 'logger'

=begin

    Use the AWS Ruby SDK to get pricing data.

    https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Pricing/Client.html#get_products-instance_method



=end

client           = Aws::Pricing::Client.new
log              = Logger.new(STDOUT)
start_ts         = Time.now.to_i
output_file_name = %Q(#{start_ts}-aws-pricing.json)

results = []
c = 0 
resp = client.get_products( { service_code: "AmazonEC2" })
until resp.next_token.nil?
    c += 1
    msg = sprintf("%6d Get next token (%s)...", c, resp.next_token[0..20])
    log.info msg
    resp = client.get_products({ 
        service_code: "AmazonEC2",
        next_token: resp.next_token,
        max_results: 100
    })  
    results += resp.price_list.map{ |o| JSON.parse(o) }
    break if c > 10
end

out_file = File.new(output_file_name, 'w+')
out_file.write(JSON.dump(results))
out_file.close
