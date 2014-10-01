server {
    listen 80;
    listen 443;
    ssl    on;
    ssl_certificate    /etc/ssl/localcerts/server-bundle.crt;
    ssl_certificate_key    /etc/ssl/localcerts/server.key;

    server_name hashbang.sh;
    root /var/www/html/hashbang.sh/dist;
    index index.html;
    autoindex on;
}

#server {
#    listen         80;
#    server_name    hashbang.sh;
#    rewrite        ^ https://$server_name$request_uri? permanent;
#}
