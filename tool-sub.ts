import { finalizeEvent } from './nostr-tools/pure'
import { validateEvent } from './nostr-tools/core.ts'
import { hexToBytes } from '@noble/hashes/utils'
import { useWebSocketImplementation, Relay } from './nostr-tools/relay'
import WebSocket from 'ws'
useWebSocketImplementation(WebSocket)

const now = ()=>{return Math.floor(Date.now() / 1000)}

const sk = hexToBytes(process.env.prikey)

function sign(created_at: number, content: string, url: string): VerifiedEvent{
  return finalizeEvent({
    kind: 1,
    created_at,
    tags: [["r", url], ["t", "wordcloud"]],
    content
  }, sk)
}

const relay2 = await Relay.connect(process.env.outrelay)
console.log(`connected to ${relay2.url}`)

const url =  process.env.baseurl + Bun.argv[2]
const eve = sign(now(), "アップしたよ\n" + url + "\n#wordcloud", url)
console.log(eve)
await relay2.publish(eve)
setTimeout(()=>{relay2.close()}, 100)
