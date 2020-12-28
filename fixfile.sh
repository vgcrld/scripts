infile="$1"
uncomp="$(basename $infile | cut -d. -f1-7)"

if zcat "$infile" | sed 's/nustanix/nutanix/' >"$uncomp"; then
    rm "$infile"
    gzip "$uncomp"
    echo "OK: $infile"
else
    echo "failed: $uncomp"
fi
