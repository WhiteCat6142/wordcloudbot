#!/usr/bin/bash
mkdir /home/bun/.oci
cp /env/config /home/bun/.oci/config
/root/bin/oci setup repair-file-permissions --file /home/bun/.oci/config
cp /env/prikey.pem /home/bun/prikey.pem
/root/bin/oci setup repair-file-permissions --file /home/bun/prikey.pem
cp /env/.env /home/bun/app/wordcloudbot/.env
cd wordcloudbot
bun run ./tool.ts
