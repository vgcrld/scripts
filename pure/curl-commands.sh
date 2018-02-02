# Get the token. Best to do this from gui
token=`curl -v -k -H 'Content-Type: application/json' -d '{ "username": "pureuser", "password": "wordpass" }' -X POST https://192.168.241.240/api/1.12/auth/apitoken 2>1 | grep api_token`

# Create a session, get the cookie
cookie=`curl -v -k -H 'Content-Type: application/json' -d "${token}" -X POST https://192.168.241.240/api/1.12/auth/session 2>&1 | awk '/Set-Cookie: /{gsub("< Set-Cookie:","",$0); print $0}'`

# Get something
curl -v -k -H 'Content-Type: application/json' --cookie "${cookie}" -X GET https://192.168.241.240/api/1.12/array

curl -v -k -H 'Content-Type: application/json' --cookie "${cookie}" -X GET https://192.168.241.240/api/1.12/volume



