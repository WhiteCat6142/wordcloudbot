# Word Cloud Bot

Require [bun](https://bun.sh/)

Config file in .env

### Run

```sh
bun run . /tool.ts
```

### Install

```sh
git submodule update --init
cp nostr-tools/package.json package.json
bun install
bun install ws
cd nostr-wordcloud
pip install -r requirements.txt
```

Install Noto Sans CJK and set up mecab-ipadic-utf8.
