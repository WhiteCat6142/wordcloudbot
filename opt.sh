#!/usr/bin/bash
nostrf=nostr-cloud-$(date +%Y%m%d%H%M)

source ./.env

cd nostr-wordcloud
python3 ./main.py --noshow -o ${nostrf}.png --relay  ${relay} --limit 200 --font ${font}
pngquant --ext -2.png 16 ${nostrf}.png
oci os object put -ns ${namespace} -bn ${bucket} --name ${nostrf}.png --file ./${nostrf}-2.png --content-type "image/png" --cache-control "public, max-age=604800, immutable"
cd ..
bun run "./tool-sub.ts" ${nostrf}.png

