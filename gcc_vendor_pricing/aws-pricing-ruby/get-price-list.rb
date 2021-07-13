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
REGIONS          = {
    "us-east-1"                 => "US East (N. Virginia)",
    "us-east-2"                 => "US East (Ohio)",
    "us-west-1"                 => "US West (N. California)",
    "us-west-2"                 => "US West (Oregon)",
    "us-gov-west-1"             => "GovCloud (US Northwest)",
    "ca-central-1"              => "Canada (Montreal) ",
    "eu-west-1"                 => "EU (Ireland)",
    "eu-west-2"                 => "EU (London)",
    "eu-central-1"              => "EU (Frankfurt)",
    "ap-southeast-1"            => "Asia Pacific (Singapore)",
    "ap-southeast-2"            => "Asia Pacific (Sydney)",
    "ap-south-1"                => "Asia Pacific (Mumbai)",
    "ap-northeast-1"            => "Asia Pacific (Tokyo)",
    "ap-northeast-2"            => "Asia Pacific (Seoul)",
    "sa-east-1"                 => "South America (Saõ Paulo)",
    "cn-north-1"                => "China (Beijing)",
}

# Get products is the pricing routine
def get_products(options: nil, name: 'generic', limit: 1000)
    LOG.info("Getting pricing for #{name}")
    results = []
    err = 0
    c = 0 
    next_token = nil
    while true
        begin
            default_options = {
                next_token: next_token
                # max_results: 10000,
            }
            default_options.merge!( options ) unless options.nil?
            resp = CLIENT.get_products(default_options)
            results += resp.price_list.map{ |o| JSON.parse(o) }
            next_token = resp.next_token
            break if next_token.nil?
            LOG.info(sprintf("Get next token (%5d): #{next_token[0..20]}...",c))
            c += 1
            if c > limit
                LOG.warn("Quitting early. Limit reached: #{limit}")
                break
            end
        rescue => e
            LOG.error(e.message)
            err += 1
            if err > 2
                LOG.error("Quitting, error limit reached.")
                exit 1
            end
        end
    end
    out_file = File.new("pricing/aws-pricing-products-#{name}.json", 'w+')
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

def merge_all_files(name: 'aws-pricing.json')
    ret = []
    files = Dir.glob('pricing/*.json')
    files.each{ |file| ret << JSON.parse(File.new(file).read) }
    ret.flatten!
    File.new(name,'w').write(JSON.dump(ret))
    return nil
end

get_products( name: "storage-e1", options: { service_code: "AmazonEC2", filters: [ { type: "TERM_MATCH", field: "productFamily",   value: "storage" },  { type: "TERM_MATCH", field: "location", value: REGIONS['us-east-1'], } ] } )
get_products( name: "storage-e2", options: { service_code: "AmazonEC2", filters: [ { type: "TERM_MATCH", field: "productFamily",   value: "storage" },  { type: "TERM_MATCH", field: "location", value: REGIONS['us-east-2'], } ] } )
get_products( name: "storage-w1", options: { service_code: "AmazonEC2", filters: [ { type: "TERM_MATCH", field: "productFamily",   value: "storage" },  { type: "TERM_MATCH", field: "location", value: REGIONS['us-west-1'], } ] } )
get_products( name: "storage-w2", options: { service_code: "AmazonEC2", filters: [ { type: "TERM_MATCH", field: "productFamily",   value: "storage" },  { type: "TERM_MATCH", field: "location", value: REGIONS['us-west-2'], } ] } )
get_products( name: "linux-e1",   options: { service_code: "AmazonEC2", filters: [ { type: "TERM_MATCH", field: "operatingSystem", value: "Linux", },   { type: "TERM_MATCH", field: "location", value: REGIONS['us-east-1'], } ] } )
get_products( name: "linux-e2",   options: { service_code: "AmazonEC2", filters: [ { type: "TERM_MATCH", field: "operatingSystem", value: "Linux", },   { type: "TERM_MATCH", field: "location", value: REGIONS['us-east-2'], } ] } )
get_products( name: "linux-w1",   options: { service_code: "AmazonEC2", filters: [ { type: "TERM_MATCH", field: "operatingSystem", value: "Linux", },   { type: "TERM_MATCH", field: "location", value: REGIONS['us-west-1'], } ] } )
get_products( name: "linux-w2",   options: { service_code: "AmazonEC2", filters: [ { type: "TERM_MATCH", field: "operatingSystem", value: "Linux", },   { type: "TERM_MATCH", field: "location", value: REGIONS['us-west-2'], } ] } )
get_products( name: "windows-e1", options: { service_code: "AmazonEC2", filters: [ { type: "TERM_MATCH", field: "operatingSystem", value: "Windows", }, { type: "TERM_MATCH", field: "location", value: REGIONS['us-east-1'], } ] } )
get_products( name: "windows-e2", options: { service_code: "AmazonEC2", filters: [ { type: "TERM_MATCH", field: "operatingSystem", value: "Windows", }, { type: "TERM_MATCH", field: "location", value: REGIONS['us-east-2'], } ] } )
get_products( name: "windows-w1", options: { service_code: "AmazonEC2", filters: [ { type: "TERM_MATCH", field: "operatingSystem", value: "Windows", }, { type: "TERM_MATCH", field: "location", value: REGIONS['us-west-1'], } ] } )
get_products( name: "windows-w2", options: { service_code: "AmazonEC2", filters: [ { type: "TERM_MATCH", field: "operatingSystem", value: "Windows", }, { type: "TERM_MATCH", field: "location", value: REGIONS['us-west-2'], } ] } )

merge_all_files


