#!/bin/bash
set -e

# In all scenarios, proceed to prepare the settings file
cat << EOF > /etc/mailman.cfg
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
url: postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}

[mta]
incoming: mailman.mta.postfix.LMTP
outgoing: mailman.mta.deliver.deliver
lmtp_host: ${MAILMAN_HOST}
lmtp_port: 8024
smtp_host: ${POSTFIX_HOST}
smtp_port: ${POSTFIX_PORT}

[webservice]
hostname: localhost
port: 8001
use_https: no
admin_user: ${MAILMAN_ADMIN_USER}
admin_pass: ${MAILMAN_ADMIN_PASSWORD}
EOF

cat << EOF > /etc/hyperkitty.cfg
[general]
base_url: http://${HYPERKITTY_HOST}:${HYPERKITTY_PORT}/archives
api_key: ${HYPERKITTY_ARCHIVER_API_KEY}
EOF


if [ "$1" = 'start' ]; then
	# Main run behaviour, which is done directly to the master
	# because we want it in the foreground, not background
	exec gosu mailman master "$@"  # note that mailman is the user, master the command
fi

if [ "$1" = 'stop' ] ; then
	# This is not allowed
	echo "Docker does not support `stop`"
	exit 2
fi

for word in "help aliases conf create import21 info inject lists members qfile remove reopen restart shell status unshunt version withlist" ; do
	if [ "$1" = "$word" ] ; then
		gosu mailman exec mailman "$@"
	fi
done

# It doesn't seem a mailman subcommand, execute it in the shell directly
exec "$@"
