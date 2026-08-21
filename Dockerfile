FROM node:20-alpine@sha256:fb4cd12c85ee03686f6af5362a0b0d56d50c58a04632e6c0fb8363f609372293

WORKDIR /app

COPY api/package*.json ./api/
WORKDIR /app/api
RUN npm ci --omit=dev

COPY api/ .

RUN addgroup -S app && adduser -S app -G app
USER app

EXPOSE 3000

CMD ["node", "server.js"]
