#!/bin/bash -e

/bin/echo '--> Removing requiretty default from sudoers.'
/bin/sed -i \
  -e 's~^Defaults requiretty~#Defaults requiretty~' \
	/etc/sudoers
