# KH | API Anything — cloud server for Claude mobile / web (remote MCP connector).
# Runs `api-anything serve` with headless Chromium so every tier (HTTP, in-page fetch, page run) works.
FROM node:22-bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends chromium fonts-liberation fonts-noto-color-emoji ca-certificates tini \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package.json package-lock.json tsconfig.json tsconfig.build.json ./
COPY src ./src
COPY sites ./sites
COPY skills ./skills
RUN npm ci --ignore-scripts && npm run build && npm prune --omit=dev

ENV NODE_ENV=production \
    API_ANYTHING_HOME=/data \
    PORT=8787
VOLUME ["/data"]
EXPOSE 8787

# API_ANYTHING_TOKEN must be set at runtime (openssl rand -hex 32).
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["sh", "-c", "test -n \"$API_ANYTHING_TOKEN\" || { echo 'API_ANYTHING_TOKEN is not set' >&2; exit 1; }; exec node dist/cli.js serve --host 0.0.0.0 --port \"$PORT\""]
