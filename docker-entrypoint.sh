#!/bin/bash
set -e

# In all scenarios, proceed to prepare the settings file
envsubst << EOF > /etc/mailman.cfg
[mailman]
# This address is the "site owner" address.
# It should point to a human.
site_owner: ${MAILMAN_SITE_OWNER}

[paths.here]
# Everything in the same directory
var_dir: /opt/mailman/var

[archiver.hyperkitty]
class: mailman_hyperkitty.Archiver
enable: yes
configuration: /etc/hyperkitty.cfg

[database]
class: mailman.database.postgresql.PostgreSQLDatabase
url: postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DATABASE}

[webservice]
hostname: localhost
port: 8001
use_https: no
admin_user: ${MAILMAN_ADMIN_USER}
admin_pass: ${MAILMAN_ADMIN_PASS}
EOF

envsubst << EOF > /etc/hyperkitty.cfg
[general]
base_url: http://${HYPERKITTY_HOST}:${HYPERKITTY_PORT}/archives
api_key: ${HYPERKITTY_ARCHIVER_API_KEY}
EOF


