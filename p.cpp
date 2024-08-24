#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>

#include <thread>
#include <iostream>
#include <optional>
#include <map>
#include <string>

#include <nostr_event_yyjson.hpp>
#include <utils.hpp>
#include <nip19.hpp>
#include "nostr_subscription.hpp"
#include "nostr_relay_interface.hpp"
#include "nostr_relay.hpp"
#include "nostr_relay_simple.hpp"
#include "nostr_relay_libhv.hpp"

#include <ctime>

using namespace cpp_nostr;

std::string getPubkey(const char *nsec)
{
    std::vector<uint8_t> sk = hex2bytes(std::string(nsec));
    auto pk = *NostrEventYYJSON::get_publickey(sk);
    return bytes2hex(pk.data(),pk.size());
}

std::string getnpub(const char *nsec)
{
    std::vector<uint8_t> sk = hex2bytes(std::string(nsec));
    auto pk = *NostrEventYYJSON::get_publickey(sk);
    return NIP19::encode("npub", pk);
}

void push()
{
  const char* command = "bash ./opt.sh";
  FILE* fp = popen(command, "r");
  if (fp == NULL) return;
  char buffer[1024];
  while (fgets(buffer, sizeof(buffer), fp) != NULL) {
    strtok(buffer,"\n\0");
    std::cout << buffer << std::endl;
  }
  pclose(fp);
}

time_t now()
{
    time_t n;
    std::time(&n);
    return n;
}

int main() {
    char *zzz = "relay";
    char* relay0 = std::getenv(zzz);
//    if ((relay0 == nullptr) || (prikey == nullptr))
//   return 0;

    NostrRelayLibhv relay;
    NostrRelaySimple rx(&relay);
    relay.connect(std::string(relay0));

    const char* prikey = std::getenv("prikey");
    NostrEventKinds list{1};
    std::map<std::string, std::vector<std::string>> list2{{"#p", {getPubkey(prikey)}}};
    NostrSubscription subx{
        .kinds = list,
        .tags = list2,
        .since = (now()),
        .limit = 0};
    std::cout << subx.encode() << std::endl;

    NostrEventCreatedAt last = 0;
    std::string npubt = "nostr:" + (getnpub(prikey));
    rx.subscribe([&npubt,&last](NostrEvent &ev)
                 {
                 std::cout << "we got the event:" << NostrEventYYJSON::encode(ev) << std::endl; 
                 const auto t = ev.created_at;
                 auto c = ev.content;
                 if (((t - last) > 360)&&(c.find(npubt)!=std::string::npos)){
                 last=t;
                 push();
    }}, subx);
    while(true)
        std::this_thread::sleep_for(std::chrono::seconds(1));
    return 0;
}
