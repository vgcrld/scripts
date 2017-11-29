require 'json'
require 'awesome_print'

fulltag = "Servers:John"

request = {
    "tags" => [
      {
        "id"           => "#{fulltag}",
        "attributes"   => {
          "selectable" => true,
          "vframe"     => true
        }
      }
    ],
    "objects"          => [
      0,1,2,3,4,55
    ]
}

ap request
puts request.to_json
