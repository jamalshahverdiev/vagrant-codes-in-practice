#### Find all TAG-ed tasks:
```bash
$ grep -A1 tags nginx_playbook.yml | grep ' - ' | uniq
```

#### Install EPEL repository with selected tag **install-epel**:
```bash
$ ansible-playbook nginx_playbook.yml --tags 'install-epel'
```

#### Install and PATCH NGINX for DEBIAN and CentOS:
```bash
$ ansible-playbook nginx_playbook.yml --tags 'install-nginx,pacth-nginx'
```

#### Configure template, start nginx and open firewall with tags:
```bash
$ ansible-playbook nginx_playbook.yml --tags 'nginx-template,nginx-running,nginx-open-firewall'
```

#### Skip Tag **patch-nginx**:
```bash
$ ansible-playbook nginx_playbook.yml --skip-tags 'patch-nginx'
```

#### Install and configure nginx fro **inginx_playbook.yml** playbook with tag **nginx** which, will install nginx only for 2 hosts:
```bash
$ ansible-playbook nginx_playbook.yml --tags 'nginx'
```

#### Skip and install together
```bash
$ ansible-playbook nginx_playbook.yml --tags 'install-nginx' --skip-tags 'always'
```

#### Execute all **tagged** tasks:
```bash
$ ansible-playbook nginx_playbook.yml --tags 'tagged'
```

#### Execute all **not tagged** tasks:
```bash 
$ ansible-playbook nginx_playbook.yml --tag 'untagged'
```

#### Run entire playbook:
```bash
$ ansible-playbook nginx_playbook.yml --tag 'all'
```
