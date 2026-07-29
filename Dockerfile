FROM node:22-alpine

ARG BUILD_VERSION=local
ENV BUILD_VERSION=${BUILD_VERSION}

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

EXPOSE 5000

CMD ["npm", "start"]
