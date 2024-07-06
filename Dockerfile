ARG ROOT_CONTAINER=oven/bun:1.1.18-slim

FROM $ROOT_CONTAINER

ENV DEBIAN_FRONTEND noninteractive

RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    git bash python3-pip mecab mecab-ipadic-utf8 pngquant unzip curl fonts-noto-cjk && \
    echo "dicdir=/var/lib/mecab/dic/ipadic-utf8" > /usr/local/etc/mecabrc && \
    curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh -o ./install.sh && \
    bash ./install.sh --no-tty --accept-all-defaults

RUN git clone https://github.com/WhiteCat6142/wordcloudbot.git --recursive --depth 1 && \
    cd wordcloudbot && \
    cp nostr-tools/package.json package.json && \
    bun install && \
    bun install ws && \
    pip install -r nostr-wordcloud/requirements.txt
    
COPY entry.sh /home/bun

CMD sh /home/bun/entry.sh
