server {
    listen 80;
    listen 443;
    ssl    on;
    ssl_certificate    /etc/nginx/ssl/server-bundle.crt;
    ssl_certificate_key    /etc/nginx/ssl/server.key;

    server_name hashbang.sh;
    root /var/www/html/hashbang.sh/dist;
    index index.html;
}

#server {
#    listen         80;
#    server_name    hashbang.sh;
#    rewrite        ^ https://$server_name$request_uri? permanent;
#}
