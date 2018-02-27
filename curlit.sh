#!/usr/bin/sh


curl -u vgcrld \
     -H "Content-Type: application/json" \
     -X GET \
     -d '{}' \
     https://api.github.com/authorizations



