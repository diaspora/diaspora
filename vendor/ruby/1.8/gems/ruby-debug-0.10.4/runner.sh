#!/usr/bin/env bash

ruby=${RUBY:-ruby}
dir=`dirname $0`
rdebug=${RDEBUG:-${dir}/bin/rdebug}
$ruby -I${dir}/ext:${dir}/lib:${dir}/cli -- $rdebug $*
exit $?
