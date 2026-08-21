FROM node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f7166196e36a5501df7a3aa32

WORKDIR /app

RUN apk update && apk upgrade --no-cache && rm -rf /var/cache/apk/*

COPY api/package*.json ./api/
WORKDIR /app/api
# npm (bundled in the base image) is a build-time tool the app never calls at
# runtime — CMD only runs `node server.js`. Delete it in the same layer once
# it's done its job, so its own vulnerable transitive deps (npm's internal
# node_modules, not ours) don't ship in the final image.
RUN npm ci --omit=dev && \
    rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack

COPY api/ .

RUN addgroup -S app && adduser -S app -G app
USER app

EXPOSE 3000

CMD ["node", "server.js"]
