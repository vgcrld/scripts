require 'aws-sdk-pricing'
require 'awesome_print'
require 'logger'

#
#
#   Use the AWS Ruby SDK to get pricing data.
#
#   https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Pricing/Client.html#get_products-instance_method
#
#   get_products
#   describe_services
#

LOG              = Logger.new(STDOUT)
CLIENT           = Aws::Pricing::Client.new

# Get products is the pricing routine
def get_products(options: nil, limit: 10)
    results = []
    err = 0
    c = 0 
    next_token = nil
    while true
        begin
            default_options = {
                next_token: next_token,
                max_results: 100,
            }
            default_options.merge!( options ) unless options.nil?
            resp = CLIENT.get_products(options)
            results += resp.price_list.map{ |o| JSON.parse(o) }
            next_token = resp.next_token
            break if next_token.nil?
            LOG.info(sprintf("Get next token: #{next_token}"))
            c += 1
            break if c > limit
        # rescue => e
        #     LOG.error(e.message)
        #     err += 1
        #     break if err > 100
        end
    end
    out_file = File.new("#{Time.now.to_i}-aws-pricing-products.json", 'w+')
    out_file.write(JSON.dump(results))
    out_file.close
end

# Get the service product list 
def describe_services()
    results = []
    err = 0
    next_token = nil
    while true
        begin
            resp = CLIENT.describe_services({ 
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


get_products(
    options: 
    {
        service_code: "AmazonEC2",
        filters: [
            {
                type: "TERM_MATCH",
                field: "ServiceCode",
                value: "AmazonEC2"
            },
            {
                type: "TERM_MATCH",
                field: "volumeType",
                value: "Provisioned IOPS"
            },
            {
                type: "TERM_MATCH",
                field: "location",
                value: "US West (N. California)"
            },
        ]
    }  
)

# get_products(client, service_code: "AmazonGuardDuty")
# get_products(client, limit: 1)

# describe_services(client)