import { getPublicKey } from './nostr-tools/pure'
import { bytesToHex, hexToBytes } from '@noble/hashes/utils'
import * as nip19 from 'nostr-tools/nip19'
import { useWebSocketImplementation, Relay } from './nostr-tools/relay'
import WebSocket from 'ws'
useWebSocketImplementation(WebSocket)

const sk = hexToBytes(process.env.prikey)
const pk = getPublicKey(sk)
const npub = nip19.npubEncode(pk)

const now = ()=>{return Math.floor(Date.now() / 1000)}

const relay = await Relay.connect(process.env.relay)
console.log(`connected to ${relay.url}`)

function push(t: number): void{
      const proc = Bun.spawn(["sh", "./opt.sh"], {stdin:"ignore", stdout:"ignore"});
      proc.unref();
}

let last = now()
const req1 = {kinds: [1], "#p":[pk], since:now()}
const sub = relay.subscribe([req1], {
  onevent(ev) {
    console.log('we got the event:', ev)
    const t = ev["created_at"]
    const c = ev["content"]
    if (((t - last) > 360)&&(c.includes("nostr:"+npub))){
      push(t).then()
      last=t
    }
  },
  oneose() {}
})

for await (const chunk of Bun.stdin.stream()) {
  const chunkText = Buffer.from(chunk).toString()
  if (chunkText.trim()==="exit"){
    sub.close()
    relay.close()
    break
  }
}

