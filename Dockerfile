FROM kirillkonshin/nginx-nodejs:latest

RUN mkdir -p /usr/share/nginx/html

ADD ./package.json /usr/share/nginx/html

WORKDIR /usr/share/nginx/html

RUN npm install

ADD . /usr/share/nginx/html

COPY ./nginx.conf /etc/nginx/nginx.conf

RUN npm run build

CMD nginx -g 'daemon off;'
