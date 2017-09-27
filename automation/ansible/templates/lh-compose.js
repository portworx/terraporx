version : '2'
services :

  px-lighthouse :
    image : portworx/px-lighthouse
    restart : always
    container_name : px-lighthouse
    network_mode : "bridge"
    volumes :
      - /var/log:/var/log
    ports :
      - "80:80"
    depends_on :
      - influx-px
    links :
      - influx-px
    environment :
      - PWX_INFLUXDB="http://influx-px:8086"
      - PWX_INFLUXUSR={{ admin_user }}
      - PWX_INFLUXPW={{ admin_password }}
      - PWX_HOSTNAME="http://{{ hostvars[groups['lighthouse'][0]].IP }}"
      - PWX_PX_PRECREATE_ADMIN=true
      - PWX_PX_COMPANY_NAME=yourcompany
      - PWX_PX_ADMIN_EMAIL=portworx@yourcompany.com
    entrypoint :
      - /bin/bash
      - /lighthouse/on-prem-entrypoint.sh
      - -k
      - {% for host in members %}etcd:http://{{ hostvars[host].IP}}:2379{{ '\n' if loop.last else ','}}{% endfor %}
      - -d
      - http://{{ admin_user }}:{{ admin_password}}@http://{{ hostvars[groups['lighthouse'][0]].IP }}:8086

  influx-px :
    image : tutum/influxdb
    restart : always
    container_name : influx-px
    network_mode : "bridge"
    volumes :
      - /var/lib/influxdb:/data
    ports :
      - "8083:8083"
      - "8086:8086"
    environment :
      - MYSQL_ALLOW_EMPTY_PASSWORD=true
      - ADMIN_USER={{ admin_user }}
      - INFLUXDB_INIT_PWD={{ admin_password }}
      - PRE_CREATE_DB="px_stats"

