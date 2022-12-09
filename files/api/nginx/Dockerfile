FROM nginx:latest

RUN rm /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/nginx.conf
COPY api.conf /etc/nginx/conf.d/api.conf

WORKDIR /

EXPOSE 8080
