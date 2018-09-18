# Do same this as before
# Copy/paste this to linux workstation as script.sh
# chmod +x script.sh
# run with:
# USERNAME={your username} PASSWORD={the password} URL={ip address:port} ./script.sh
######################################################################################

dir="pure_system_pulls"
mkdir -p $dir
cd $dir

##################
# Get config Data
#################

# Get all types of stuff
curl -k https://$USERNAME:$PASSWORD@$URL/api/json/types > types.json
# make directory to hold files for details about each type of thing
mkdir -p configs
# grep out the urls to get each instance, of each type of thing
type_urls=$(cat types.json | grep href | awk -F\": '{print $NF}' | tr -d '", \t' | grep -v '/$'  | sed 's@https://@@g')
# start looping through those urls
for url in $(echo "$type_urls")
do
  # get the name of the thing from the url IE https://$URL/api/json/types/volumes => volumes
  type_of_thing=$(echo "$url" | awk -F/ '{print $NF}')
  # make a directory to hold all the stuff for this type of thing
  mkdir -p configs/$type_of_thing
  # make a file in that directory called ids.json that has the urls to get info on each instance of thing of this type
  ids_file="config/$type_of_thing/ids.json"
  # make call to get instances of this type
  curl -k https://$USERNAME:$PASSWORD@$url > $ids_file
  # now get url to get details about each instance
  ids_to_follow=$(cat $ids_file | grep href | awk -F\": '{print $NF}' | tr -d '", \t' | grep -v '/$'  | sed 's@https://@@g')
  # loop over all instaces of type

  for type_of_thing_instance_url in $(echo "$ids_to_follow")
  do
    # get id of thing from url IE https://$URL/api/json/types/volumes/44 => 44
    id_of_thing=$(echo "$url" | awk -F/ '{print $NF}')
    # get details for thing (of type), with id from line above and put in (config/volumes/44.json) following examples from above
    curl -k https://$USERNAME:$PASSWORD@$type_of_thing_instance_url > config/$type_of_thing/$id_of_thing.json
  done
done


# And actually it looks like those calls above get trend data too, so this should take care of everything
# we need for XtremIO
