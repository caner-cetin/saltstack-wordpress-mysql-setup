##########################################################################################
# User ve group ID’si 2024, home dizini /home/krt,                                       #
# default shell’i /bin/bash,  kartaca adında bir kullanıcı oluşturun.                    #
# parolası kartaca2024 olan kartaca adında bir kullanıcı oluşturun.                      #
# (Kullanıcı parola bilgisini state file üzerinde değil pillar data üzerinde tutun.)     #
##########################################################################################
create_group_2024:
# ensure that the group is present, does nothing if the group already exists
  group.present:
    - name: '{{ pillar['kartaca']['username'] }}-2024-group'
    - gid: 2024
        
create_kartaca_user:
  # ensure that the user is present, does nothing if the user already exists
  user.present:
    - name: '{{ pillar['kartaca']['username'] }}'
    - password: '{{ pillar['kartaca']['password'] }}'
    - uid: 2024
    - gid: 2024
    - home: /home/krt
    - shell: /bin/bash
##########################################################################################
# Kartaca kullanıcısına sudo yetkisi verin ve bu kullanıcı Ubuntu üzerinde sudo apt      #
# komutunu, Centos üzerinde sudo yum komutunu parola yazmadan çalıştırabilsin.           #
##########################################################################################
{% if grains['os_family'] == 'RedHat' %}
add_kartaca_user_to_sudoers_redhat:
  cmd.run:
    - name: "usermod -aG wheel {{ pillar['kartaca']['username'] }}"
{% elif grains['os_family'] == 'Debian' or grains['os_family'] == 'Ubuntu' %}
add_kartaca_user_to_sudoers_debian:
  cmd.run:
    - name: "usermod -aG sudo {{ pillar['kartaca']['username'] }}"
{%endif%}

##########################################################################################
# Sunucu timezone’unu Istanbul olarak ayarlayın.                                         #
##########################################################################################
#
# see https://github.com/saltstack/salt/issues/61296
ensure_timezone_file_exists:
  cmd.run:
    - name: touch /etc/localtime
    - creates: /etc/localtime

set_timezone_to_istanbul:
    timezone.system:
      - name: Europe/Istanbul
      - utc: True
##########################################################################################
# IP Forwarding’i kalıcı olarak enable edin.                                             #
##########################################################################################
enable_ip_forwarding:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1
    # uncomment if salt cant locate the sysctl.conf by itself
    # - config: /etc/sysctl.conf
##########################################################################################
# Terminalden htop, tcptraceroute, ping, dig, iostat, mtr komutlarını çalıştırabilmek    #
# için gerekli paketleri kurun.                                                          #
##########################################################################################
{% if grains['os_family'] == 'RedHat' %}
tools_redhat:
  cmd.run:
    - names:
      - yum install -y epel-release
      - yum install -y htop tcptraceroute iputils bind-utils sysstat mtr
{% elif grains['os_family'] == 'Debian' or grains['os_family'] == 'Ubuntu' %}
tools_debian:
  cmd.run:
    - names:
      - apt-get update
      - apt-get install -y htop tcptraceroute iputils-ping dnsutils sysstat mtr-tiny
{%endif%}
##########################################################################################
# https://www.hashicorp.com/official-packaging-guide adresindeki bilgiler ile Hashicorp  #
# reposunu sisteme ekleyin ve Terraform paketinin v1.6.4 versiyonunu kurun.              #
##########################################################################################
{% if grains['os_family'] == 'RedHat' %}
add_hashicorp_repo_to_system_redhat:
  cmd.run:
    - names:
      - yum install -y gpg
      - mkdir -p /usr/share/keyrings
      - wget -O /tmp/hashicorp-archive-key.gpg https://apt.releases.hashicorp.com/gpg
      - gpg --import /tmp/hashicorp-archive-key.gpg
      - rm /tmp/hashicorp-archive-key.gpg
      - mkdir -p /etc/yum.repos.d
      - wget -O /etc/yum.repos.d/hashicorp.repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
      - yum update -y
      - yum install -y terraform
{%endif%}
##########################################################################################
# 192.168.168.128/28 IP bloğundaki her IP adresi için /etc/hosts dosyasına               #
# kartaca.local adresini çözecek şekilde host kaydı ekleyin.                             # 
# Bu değişikliği Salt state dosyası içinde for döngüsü ile yapın.                        #
##########################################################################################
{% for i in range(1, 16) %}
add_host_{{ i }}:
  file.append:
    - name: /etc/hosts
    - text: "192.168.168.{{ 128 + i }}/28 kartaca.local"
{% endfor %}
