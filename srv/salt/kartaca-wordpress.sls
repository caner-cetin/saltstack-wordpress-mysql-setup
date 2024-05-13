
##########################################################################################
# Nginx web server kurulumu yapın.                                                       # 
#                                                                                        #
# Nginx servisini, sunucu her yeniden başladığında otomatik başlayacak                   # 
# şekilde yapılandırın.                                                                  #
#                                                                                        #           
# /etc/nginx/nginx.conf dosya içeriği her güncellendiğinde,                              #
# Nginx servisini reload edecek şekilde yapılandırın.                                    #
#                                                                                        #           
# Nginx yapılandırmasını Salt ile yönetin,                                               #         
# Salt state her uygulandığında sunucu üzerindeki /etc/nginx/nginx.conf                  #
# dosyası Salt state dosyası ile aynı dizinde bulunan files dizinindeki                  #
# nginx.conf dosyasından güncellensin.                                                   #
##########################################################################################
create_ssl_folder_if_not_exists:
  cmd.run:
    - name: mkdir -p /etc/nginx/ssl
    - creates: /etc/nginx/ssl
nginx_ssl_certificate:
  file.managed:
    - name: /etc/nginx/ssl/nginx.crt
    - source: salt://nginx/ssl/nginx.crt
nginx_ssl_key:
  file.managed:
    - name: /etc/nginx/ssl/nginx.key
    - source: salt://nginx/ssl/nginx.key
nginx:
  pkg.installed:
    - name: nginx

nginx_service:
  service:
    - running
    - name: nginx
    - enable: True
    - reload: True
    - watch:
      - file: nginx_service
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/conf/nginx.conf

nginx_html_folder:
  file.directory:
    - name: /usr/share/nginx/html
##########################################################################################
# Sunucuda WordPress çalıştırabilmek için gerekli PHP paketlerini kurun,                 #
# gerekli Nginx/PHP yapılandırmalarını yapın.                                            #
##########################################################################################
firewalld_service:
  service.running:
    - name: firewalld
    - enable: True

enable_firewall_for_https:
  firewalld.present:
    - name: public
    - ports:
      - 443/tcp

php_fpm:
  pkg.installed:
    - names:
      - php-fpm 
      - php-mysqlnd

fpm_ownership_to_nginx:
  file.replace:
    - name: "/etc/php-fpm.d/www.conf"
    - pattern: "user = apache"
    - repl: "user = nginx"

fpm_group_to_nginx:
  file.replace:
    - name: "/etc/php-fpm.d/www.conf"
    - pattern: "group = apache"
    - repl: "group = nginx"

fpm_service:
  service.running:
    - name: php-fpm
    - enable: True
    - require:
      - pkg: php-fpm

nginx_default_document_root_to_user:
  cmd.run:
    - name: "chown -R {{ pillar['kartaca']['username'] }}.2024 /usr/share/nginx/html/"
##############################################################################################
# https://wordpress.org/download adresinden WordPress arşiv dosyasını /tmp dizinine indirin. #
##############################################################################################
download_wordpress:
  cmd.run:
    - name: "wget -O /tmp/wordpress.tar.gz https://wordpress.org/wordpress-latest.tar.gz"
    - creates: "/tmp/wordpress.tar.gz"
##############################################################################################
# WordPress arşiv dosyasını /var/www/wordpress2024 dizinine açın.                            #
##############################################################################################
extract_wordpress:
  cmd.run:
    - name: "mkdir -p /var/www/wordpress2024 && tar -xzf /tmp/wordpress.tar.gz -C /var/www/wordpress2024"
    # - creates: "/var/www/wordpress2024"

symlink_wordpress_to_nginx_html_folder:
  file.symlink:
    - name: /usr/share/nginx/html/wordpress
    - target: /var/www/wordpress2024/wordpress

wp-config:
  service:
    - name: php-fpm
    - running
    - enable: True
    - reload: True
    - watch:
      - file: wp-config
  file.managed:
    - name: /var/www/wordpress2024/wordpress/wp-config.php
    - source: salt://wordpress/conf/wp-config.php
##############################################################################################
# Nginx servisini her ayın ilk gününde durdurup yeniden başlatacak bir cron oluşturun.       #
##############################################################################################
restart_nginx:
  cron.present:
    - name: "service nginx restart"
    - user: root
    - minute: 0
    - hour: 0
    - daymonth: 1
    - identifier: "restart_nginx_monthly"
##############################################################################################
# Nginx loglarını saatlik olarak rotate edecek, rotate olan log dosyalarını gzip ile         #
# sıkıştıracak ve sadece son 10 dosyayı saklayacak bir logrotate yapılandırması yapın.       #
##############################################################################################
create_logrotate_nginx_folder:
  file.directory:
    - name: /var/log/nginx
mount_logrotate:
  file.managed:
    - name: /etc/logrotate.d/nginx
    - source: salt://logrotate/nginx