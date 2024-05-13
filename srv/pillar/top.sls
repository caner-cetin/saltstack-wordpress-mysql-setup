base:
  '*':
    - users
    - mysql_wordpress_credentials
  # bad idea to wildcard root credentials, 
  # but we have only two machines and only one ubuntu that serves as a mysql server
  'ubuntu*':
    - mysql_root_credentials
    - mysql_backup_admin_credentials