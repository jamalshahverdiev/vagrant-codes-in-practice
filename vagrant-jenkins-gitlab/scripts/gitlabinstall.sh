#!/usr/bin/env bash

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | bash

# Config by hand /etc/gitlab/gitlab.rb in "external_url" section
# Don't forget execute command: 'gitlab-ctl reconfigure'
EXTERNAL_URL="http://$1" yum install -y gitlab-ce

