FROM node:22-alpine AS dependencies

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

FROM node:22-alpine AS runtime

ARG BUILD_VERSION=local
ENV BUILD_VERSION=${BUILD_VERSION}
ENV NODE_ENV=production

WORKDIR /app

COPY --from=dependencies /app/node_modules ./node_modules

COPY package*.json ./
COPY . .

EXPOSE 5000

USER node

CMD ["npm", "start"]