FROM node:16-buster as builder
WORKDIR /app

COPY ./js /app/js
COPY ./static /app/static
COPY ./styles /app/styles
COPY ./.env /app/.env
COPY ./package.json /app/package.json
COPY ./package-lock.json /app/package-lock.json
COPY ./webpack.config.js /app/webpack.config.js

RUN npm i && npm run build

FROM nginx:latest
WORKDIR /app

COPY --from=builder /app/build/main.css /app/main.css
COPY --from=builder /app/build/main.js /app/main.js
COPY ./markup/index.html /app/index.html
COPY ./markup/item.html /app/item.html
COPY ./markup/list.json /app/list.json
COPY ./demo.conf /etc/nginx/conf.d/default.conf