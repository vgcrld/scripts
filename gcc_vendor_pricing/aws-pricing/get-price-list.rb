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
LINUX_FILTERS    = [
    {
        field: "ServiceCode",
        type:  "TERM_MATCH",
        value: "AmazonEC2",
    },
    {
        field: "operatingSystem",
        type:  "TERM_MATCH",
        value: "Linux",
    },
    {
        field: "location",
        type:  "TERM_MATCH",
        value: REGIONS['us-east-1'],
    },
    {
        field: "operation",
        type:  "TERM_MATCH",
        value: "RunInstances",
    },
    {
        field: "capacitystatus",
        type:  "TERM_MATCH",
        value: "Used",
    },
    {
        field: "preInstalledSw",
        type:  "TERM_MATCH",
        value: "NA",
    },
    {
        field: "servicename",
        type:  "TERM_MATCH",
        value: "Amazon Elastic Compute Cloud",
    },
    {
        field: "tenancy",
        type:  "TERM_MATCH",
        value: "Shared",
    }
]
WINDOWS_FITLERS  = [
    {
        field: "ServiceCode",
        type:  "TERM_MATCH",
        value: "AmazonEC2",
    },
    {
        field: "operatingSystem",
        type:  "TERM_MATCH",
        value: "windows",
    },
    {
        field: "licenseModel",
        type:  "TERM_MATCH",
        value: "No License required",
    },
    {
        field: "location",
        type:  "TERM_MATCH",
        value: REGIONS['us-east-1'],
    },
    {
        field: "capacitystatus",
        type:  "TERM_MATCH",
        value: "Used",
    },
    {
        field: "preInstalledSw",
        type:  "TERM_MATCH",
        value: "NA",
    },
    {
        field: "servicename",
        type:  "TERM_MATCH",
        value: "Amazon Elastic Compute Cloud",
    },
    {
        field: "tenancy",
        type:  "TERM_MATCH",
        value: "Shared",
    }
]

# Get products is the pricing routine
def get_products(options: nil, name: 'generic', limit: 10)
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
            LOG.info(sprintf("Get next token: #{next_token[0..20]}..."))
            c += 1
            break if c > limit
        rescue => e
            LOG.error(e.message)
            err += 1
            break if err > 2
        end
    end
    out_file = File.new("aws-pricing-products-#{name}.json", 'w+')
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


storage = Proc.new {
    get_products(
        name: 'storage-east',
        options: 
        {
            service_code: "AmazonEC2",
            filters: [
                {
                    type: "TERM_MATCH",
                    field: "productFamily",
                    value: "storage"
                },
                {
                    type: "TERM_MATCH",
                    field: "location",
                    value: REGIONS['us-east-1'],
                },
            ]
        }  
    )
}

linux_east = Proc.new {
    get_products(
        name: 'linux-east',
        options: 
        {
            service_code: "AmazonEC2",
            filters: LINUX_FILTERS
        }  
    )
}

windows_east = Proc.new {
    get_products(
        name: 'windows-east',
        options: 
        {
            service_code: "AmazonEC2",
            filters: WINDOWS_FITLERS
        }  
    )
}

def merge_all_files(name: 'aws-pricing.json')
    ret = []
    files = Dir.glob('aws-pricing*.json')
    files.each{ |file| ret << JSON.parse(File.new(file).read) }
    ret.flatten!
    File.new(name,'w').write(JSON.dump(ret))
    return nil
end


storage.call
linux_east.call
windows_east.call

merge_all_files



# describe_services(client)


