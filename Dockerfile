ARG ROOT_CONTAINER=oven/bun:1.1.18-slim

FROM $ROOT_CONTAINER AS build

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    git bash python3-pip curl && \
    curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh -o ./install.sh && \
    bash ./install.sh --no-tty --accept-all-defaults

RUN --mount=type=cache,mode=0755,target=/root/.cache/pip \
    git clone https://github.com/WhiteCat6142/wordcloudbot.git --recursive --depth 1 && \
    cd wordcloudbot && \
    cp nostr-tools/package.json package.json && \
    bun install && \
    bun install ws && \
    pip install -r nostr-wordcloud/requirements.txt && \
    rm -rf .git && rm -rf nostr-tools/.git && rm -rf nostr-wordcloud/.git

FROM $ROOT_CONTAINER

LABEL maintainer="WhiteCat6142 <whitecat6142+git@gmail.com>"

COPY --link --from=build /home/bun/app /home/bun/app
COPY --link --from=build /usr/local/lib /usr/local/lib
COPY --link --from=build /root/bin /root/bin
COPY --link --from=build /root/lib/oracle-cli /root/lib/oracle-cli

ENV DEBIAN_FRONTEND noninteractive

RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    python3.9 mecab mecab-ipadic pngquant fonts-noto-cjk && \
    echo "dicdir=/var/lib/mecab/dic/ipadic" > /usr/local/etc/mecabrc 
    
COPY entry.sh /home/bun

CMD ["/bin/sh","/home/bun/entry.sh"]
