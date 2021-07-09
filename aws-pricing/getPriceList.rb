require 'aws-sdk-pricing'
require 'awesome_print'
require 'logger'

=begin

    Use the AWS Ruby SDK to get pricing data.

    https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Pricing/Client.html#get_products-instance_method



=end

LOG              = Logger.new(STDOUT)

client           = Aws::Pricing::Client.new

def get_products(client, service_code: "AmazonEC2")
    results = []
    err = 0
    next_token = nil
    while true
        begin
            resp = client.get_products({
                service_code: service_code,
                next_token: next_token,
                max_results: 100
            })
            results += resp.price_list.map{ |o| JSON.parse(o) }
            next_token = resp.next_token
            break if next_token.nil?
            LOG.info(sprintf("Get next token: #{next_token}"))
        rescue => e
            LOG.error(e.message)
            err += 1
            break if err > 3
        end
    end
    out_file = File.new("#{Time.now.to_i}-aws-pricing-products-#{service_code}.json", 'w+')
    out_file.write(JSON.dump(results))
    out_file.close
end

def describe_services(client)
    results = []
    err = 0
    next_token = nil
    while true
        begin
            resp = client.describe_services({ 
                max_results: 100,
                next_token: next_token
            }) 
            results += resp.services
            next_token = resp.next_token
            break if next_token.nil?
        rescue => e
            LOG.error(e.message)
            err += 1
            break if err > 3
        end
    end
    out_results = {}
    results.each{ |o| out_results[o.service_code] = o.attribute_names }
    out_file = File.new("#{Time.now.to_i}-aws-pricing-services.json", 'w+')
    out_file.write(out_results.to_json)
    out_file.close
end

describe_services(client)
get_products(client, service_code: "AmazonGuardDuty")
# get_products(client)
