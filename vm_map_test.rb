puts "Test (test.rb) is running. ( #{self.class} - #{self.object_id} )"

@orders = Hash.new
@orders[:cluster] = create_orders_by_removing_nils("cluster_raw")
@orders[:host] = create_orders_by_removing_nils("host_raw")
@orders[:vm] = create_orders_by_removing_nils("vm_raw")

#ap @orders




exit

order = create_order_by_removing_nils( cluster_raw ("cpu.usagemhz.average") )
map_by_order(:vmwarecluster, :cluster_raw, order)

# Create an order array from a given attribute and map it to a new type
order = create_order_by_removing_nils( vm_raw("datastore.read.average") )
map_by_order(:vmwarevm, :vm_raw, order,
  "datastore.read.average",
  "datastore.write.average"
)

order = create_order_by_removing_nils( host_raw("cpu.usage.average") )
map_by_order(:vmwarehostcpu, :host_raw, order)



exit
######################################################################################################
# Here is basically what is happing to create base trend data
# 1. Add a Type - a holder for this level
# 2. Add the attributes - "what we are trending" e.g. age,height,vision
# 3. Add the object - "who we are trending" e.g. bob,sue,mark,rich
# 4. Add the trend values in order of the objects
# Order is key.  e.g If there is no height for Mark @ 1416862120
# then you must pad with Nil or 0.
# Usually the trend is already @data in the transform and we are moving from one type to another
# It's not typical to be adding trend at this point? (in transform)
######################################################################################################
add_types :davis
add_attributes :davis, [:age,:height,:vision]
add_objects :davis, [:bob,:sue,:rich,:mark]
add_trend :davis, :age,    1416862120, [10,20,20,10]
add_trend :davis, :age,    1416863120, [10,20,20,10]
add_trend :davis, :height, 1416862120, [10,20,nil,10]
add_trend :davis, :height, 1416863120, [10,20,nil,10]
add_trend :davis, :vision, 1416862120, [10,20,20,10]
add_trend :davis, :vision, 1416863120, [10,20,20,10]

# Add some additional attributes
add_attributes :davis, [:_name,:_address]
add_trend :davis, :_name,  0, "Name of the family is Davis"
add_trend :davis, :_address,  0, "13 Lovalee Lane"

#ap objects :davis
#ap attributes :davis
#ap trend :davis

######################################################################################################
# Missing values will cause issues - trend will be mis-aligned, e.g.:
# add_trend :davis, "height", 1416862120, [10,20,10]   ### <-only 3 values and should be 4
#
# After we have created the base data attributes - we then map and export
# 1. map moves from one type to a new type and does calculations in the process
# 2. export prepares the data to be written from the mapped type
# Assume the above was done in vmware.rb and not in a transform.  Now we are in
# transform and creating new types and mapping.  (This is an example)
######################################################################################################

# Create a new type
add_types :mydata

# Now add the who - objects.  Objects is an array
add_objects :mydata, (concat(objects(:davis),"-data"))

# Now map from one to the other.  Here is where order matters.  The objects (4)
# Must be consistent.  So there needs to be 4 :age and :height.
map "mydata:age", (davis :age)
map "mydata:hi",  (davis :height)

# Here we create a new trend value "new" which is :age * :height
map "mydata:new", (davis :age ) * ( davis :height )

ap objects :mydata
ap trend :mydata

ap objects :davis
ap trend :davis

exit
