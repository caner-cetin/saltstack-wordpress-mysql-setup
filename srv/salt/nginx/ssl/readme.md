generated with
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./srv/salt/nginx/ssl/nginx.key -out ./srv/salt/nginx/ssl/nginx.crt -subj '/C=TR/ST=Istanbul/L=Istanbul/O=doot/OU=IT Department/CN=www.example.com'
```