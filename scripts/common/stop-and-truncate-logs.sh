#!/bin/bash -e

/bin/echo '--> Stopping logging services.'
/etc/init.d/auditd stop
/etc/init.d/rsyslog stop

/bin/echo '--> Truncate log files.'
/bin/find /var/log -type f \
  -exec /usr/bin/truncate -s 0 {} \;
