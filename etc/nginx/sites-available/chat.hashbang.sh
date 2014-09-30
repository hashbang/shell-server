server {

    listen 443;
    ssl    on;
    ssl_certificate    /etc/ssl/localcerts/server-bundle.crt;
    ssl_certificate_key    /etc/ssl/localcerts/server.key;

    server_name chat.hashbang.sh;
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";

        proxy_buffering off;
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
}

server {
    listen         80;
    server_name    chat.hashbang.sh;
    rewrite        ^ https://$server_name$request_uri? permanent;
}

