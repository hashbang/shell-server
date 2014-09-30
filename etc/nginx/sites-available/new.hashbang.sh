server {
    listen 443;
    ssl    on;
    ssl_certificate    /etc/ssl/localcerts/server-bundle.crt;
    ssl_certificate_key    /etc/ssl/localcerts/server.key;
    
    server_name new.hashbang.sh;
    location / {
    	proxy_redirect off;
    	proxy_set_header Host $host;
    	proxy_set_header X-Real-IP $remote_addr;
    	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    	proxy_pass http://127.0.0.1:8453;
    }
}

server {
    listen         80;
    server_name    new.hashbang.sh;
    rewrite        ^ https://$server_name$request_uri? permanent;
}
