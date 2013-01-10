#!/bin/sh
#
# $Id: autogen.sh,v 1.2 2004/08/20 21:22:34 bazsi Exp $
#
# This script is needed to setup build environment from checked out
# source tree. 
#

set -e

(
 pemodpath="$ZWA_ROOT/git/syslog-ng/syslog-ng-pe-modules--mainline--5.0/modules"
 for pemod in license logstore diskq confighash snmp afsqlsource rltp-proto eventlog agent-config windows-resource; do
    if [ -d $pemodpath/$pemod ]; then
        if [ -h modules/$pemod ] || [ -d modules/$pemod ]; then rm -rf modules/$pemod; fi
        ln -s $pemodpath/$pemod modules/$pemod
    fi
 done
 petests_orig="$ZWA_ROOT/git/syslog-ng/syslog-ng-pe-modules--mainline--5.0/tests"
 petests="pe-tests"
 if [ -d $petests_orig ]; then
     if [ -h $petests ] || [ -d $petests ]; then rm -rf $petests; fi
     ln -s $petests_orig $petests
 fi
)

ACLOCALPATHS=
for pth in /opt/libtool/share/aclocal /usr/local/share/aclocal; do
	if [ -d $pth ];then
		ACLOCAPATHS="$ACLOCALPATHS -I $pth"
	fi
done
# bootstrap syslog-ng itself
libtoolize --force --copy
aclocal -I m4 $ACLOCALPATHS --install
sed -i -e 's/PKG_PROG_PKG_CONFIG(\[0\.16\])/PKG_PROG_PKG_CONFIG([0.14])/g' aclocal.m4

autoheader
automake --foreign --add-missing --copy
autoconf
find -name libtool -o -name ltmain.sh | xargs sed -i -e "s,'file format pe-i386.*\?','file format \(pei\*-i386\(\.\*architecture: i386\)\?|pe-arm-wince|pe-x86-64\)',"
sed -i -e "s, cmd //c, sh -c," ltmain.sh