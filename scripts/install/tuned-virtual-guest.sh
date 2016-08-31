#!/bin/bash -e

/bin/echo '--> Installing tuned (virtual-guest).'
/usr/bin/yum -y install \
  tuned
/sbin/chkconfig tuned on
/usr/bin/tuned-adm profile \
  virtual-guest
