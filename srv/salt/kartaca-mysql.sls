##########################################################################################
# MySQL veritabanı kurulumu yapın.                                                       #  
##########################################################################################
debconf-utils: 
  pkg.installed
mysqlroot:
  debconf.set:
    - data:
        'mysql-server/root_password': {'type': 'password', 'value': {{pillar['mysql_root_credentials']['root_pwd']}}}
        'mysql-server/root_password_again': {'type': 'password', 'value': {{pillar['mysql_root_credentials']['root_pwd']}}}
mysql-server: 
  pkg.installed
mysql-client: 
  pkg.installed

mysql:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: mysql
  file.managed:
    - name: /etc/mysql/mysql.conf.d/mysqld.cnf
    - source: salt://mysql/files/mysqld.cnf

mysql_python_pkgs:
  pkg.installed:
    - pkgs:
      - libmysqlclient-dev
      - python3-dev 
      - build-essential 
      - pkg-config

python-pip:
  pkg:
    - installed
    - refresh: False

pymysql:
  pip.installed:
    - name: pymysql
    - require:
      - pkg: python-pip

firewalld:
  pkg.installed

firewalld_service:
  service.running:
    - name: firewalld
    - enable: True

enable_firewall_for_db:
  firewalld.present:
    - name: public
    - ports:
      - 3306/tcp

##########################################################################################
# MySQL servisini sunucu yeniden başladığında otomatik başlayacak şekilde yapılandırın.  #
##########################################################################################
mysql_service:
  service.running:
    - name: mysql
    - enable: True
    - require:
      - debconf: mysqlroot
      - pkg: mysql-server
      - pkg: mysql-client
      - pkg: mysql_python_pkgs
      - pkg: python-pip
      - pip: pymysql
    
##########################################################################################
# WordPress kurulumu için MySQL üzerinde veritabanı ve kullanıcı oluşturun,              #
# oluşturduğunuz kullanıcı için gerekli veritabanı yetkilerini tanımlayın.               #
##########################################################################################
{% set WORDPRESS_USERNAME = pillar['mysql_wordpress_credentials']['name']   %}
{% set WORDPRESS_PASSWORD = pillar['mysql_wordpress_credentials']['pwd']    %}
{% set WORDPRESS_DB_NAME  = pillar['mysql_wordpress_credentials']['db_name'] %}
{% set common_mysql_params = {
    'connection_user': 'root',
    'connection_pass': pillar['mysql_root_credentials']['root_pwd'],
    'connection_charset': 'utf8',
    'saltenv': [{'LC_ALL': 'en_US.utf8'}],
    'require': [{'pkg': 'mysql-server'}, {'pip': 'pymysql'}]
} %}
wordpressdb:
  mysql_database.present:
    - name: "{{ WORDPRESS_DB_NAME }}"
    - host: localhost
    - {{ common_mysql_params | yaml }}
    
wordpressdb_user_localhost:
  mysql_user.present:
    - name: "{{ WORDPRESS_USERNAME }}"
    - password: "{{ WORDPRESS_PASSWORD }}"
    - host: localhost
    - {{ common_mysql_params | yaml }}

wordpressdb_user_remote:
  mysql_user.present:
    - name: "{{ WORDPRESS_USERNAME }}"
    - password: "{{ WORDPRESS_PASSWORD }}"
    - host: "%"
    - {{ common_mysql_params | yaml }}

wordpressdb_remote_access:
  mysql_query.run:
    - name: "{{ WORDPRESS_USERNAME }}-remote-access"
    - query: "UPDATE mysql.user SET HOST='%' WHERE User='{{ WORDPRESS_USERNAME }}'"
    - database: "mysql"
    - {{ common_mysql_params | yaml }}

wordpressdb_grants_in_remote:
  mysql_grants.present:
    - name: "{{ WORDPRESS_USERNAME }}-{{ WORDPRESS_DB_NAME }}"
    - user: "{{ WORDPRESS_USERNAME }}"
    - database: "{{ WORDPRESS_DB_NAME }}.*"
    - grant: "CREATE, ALTER, INSERT, UPDATE, DELETE, SELECT, REFERENCES, DROP"
    - host: "%"
    - {{ common_mysql_params | yaml }}

#
# backup admin user and grants
# see https://dev.mysql.com/doc/mysql-enterprise-backup/4.1/en/mysqlbackup.privileges.html
# we are not using the mysql enterprise backup, but these are still needed for mysqlbackup command.
#
{% set mysql_root_credentials = pillar['mysql_root_credentials'] %}
{% set BACKUP_USERNAME    = pillar['mysql_backup_admin_credentials']['name']   %}
{% set BACKUP_PASSWORD    = pillar['mysql_backup_admin_credentials']['pwd']    %}

{% set common_mysql_params = {
    'connection_user': 'root',
    'connection_pass': pillar['mysql_root_credentials']['root_pwd'],
    'connection_charset': 'utf8',
    'saltenv': [{'LC_ALL': 'en_US.utf8'}],
    'require': [{'pkg': 'mysql-server'}, {'pip': 'pymysql'}]
} %}

backupadmin_user:
  mysql_user.present:
    - name: "{{ BACKUP_USERNAME }}"
    - password: "{{ BACKUP_PASSWORD }}"
    - host: localhost
    - {{ common_mysql_params | yaml }}

{% set backup_grants = {
    'backupadmin_all_db_grant': {'grant': 'RELOAD, SUPER, PROCESS', 'database': '*.*'},
    'backupadmin_mysql_backup_progress_grant': {'grant': 'CREATE, INSERT, DROP, UPDATE', 'database': 'mysql.backup_progress'},
    'backupadmin_mysql_backup_history_grant': {'grant': 'CREATE, INSERT, SELECT, DROP, UPDATE, ALTER', 'database': 'mysql.backup_history'},
    'backupadmin_replication_client_grant': {'grant': 'REPLICATION CLIENT', 'database': '*.*'},
    'backupadmin_replication_group_member_grant': {'grant': 'SELECT', 'database': 'performance_schema.replication_group_members'}
} %}

{% for grant_name, grant_params in backup_grants.items() %}
{{ grant_name }}:
  mysql_grants.present:
    - name: "{{ BACKUP_USERNAME }}-{{ grant_params['database'].split('.')[-1] }}"
    - user: "{{ BACKUP_USERNAME }}"
    - grant: "{{ grant_params['grant'] }}"
    - database: "{{ grant_params['database'] }}"
    - host: localhost
    - {{ common_mysql_params | yaml }}
{% endfor %}

flush_privileges:
  mysql_query.run:
    - name: "mysql-wordpress-flush-privileges"
    - query: "FLUSH PRIVILEGES"
    - database: "mysql"
    - {{ common_mysql_params | yaml }}
##########################################################################################
# Her gece 02:00’de MySQL database dump’ını /backup dizinine alacak bir cron hazırlayın. #
##########################################################################################
mysql_backup:
  cron.present:
    - name: "mysqldump -u {{ BACKUP_USERNAME }} -p {{ BACKUP_PASSWORD }} --all-databases > /backup/mysql_backup.sql"
    - user: "{{pillar['kartaca']['username']}}"
    - minute: 0
    - hour: 2
    - identifier: "MYSQL_BACKUP"