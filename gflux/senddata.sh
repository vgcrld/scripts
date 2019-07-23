
# Setup

     ts=$(ruby -e 'puts (Time.now.to_f*(1000**2)).round(0)')
   payl="sample_data_003.payload"
     db="LIVE_atsgroup"
  creds='rdavis_host1.60830870-6901-0137-65e8-4fd374e52661:608443c0-6901-0137-65e9-4fd374e52661'

# Send

curl -vkX POST -H "Content-Type: text/plain" --data-binary @${payl} -u "$creds" \
  "https://xfer1-dev.galileosuite.com:1447/ingest/influx/${db}/write?db=test"
