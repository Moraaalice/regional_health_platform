FROM node:22-alpine

WORKDIR /app

RUN apk update && apk upgrade --no-cache && rm -rf /var/cache/apk/*

COPY api/package*.json ./api/
WORKDIR /app/api
RUN npm ci --omit=dev

COPY api/ .

RUN addgroup -S app && adduser -S app -G app
USER app

EXPOSE 3000

CMD ["node", "server.js"]
