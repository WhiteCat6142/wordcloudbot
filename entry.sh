#!/usr/bin/bash
mkdir /root/.oci
cp /env/config /root/.oci/config
/root/bin/oci setup repair-file-permissions --file /root/.oci/config
cp /env/prikey.pem /home/bun/prikey.pem
/root/bin/oci setup repair-file-permissions --file /home/bun/prikey.pem
cp /env/.env /home/bun/app/wordcloudbot/.env
cd wordcloudbot
bun run ./tool.ts
