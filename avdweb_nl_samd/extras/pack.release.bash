#!/bin/bash -ex

#  pack.*.bash - Bash script to help packaging samd core releases.
#  Copyright (c) 2015 Arduino LLC.  All right reserved.
#  Modifications for SAM15X15 - Copyright (c) 2020 Abhijit Bose <https://boseji.com>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

VERSION=`grep version= platform.txt | sed 's/version=//g'`
NAME=`grep name= platform.txt| sed 's/name=//g' |sed 's/[.| ]/_/g'`

PWD=`pwd`
FOLDERNAME=`basename $PWD`
THIS_SCRIPT_NAME=`basename $0`
ARCHIVE="${NAME}_${VERSION}.tar.bz2"
EXCLUDE="--exclude=extras/** --exclude=.git* --exclude=.idea --exclude=original*.txt"

rm -f samd-$VERSION.tar.bz2

cd ..
tar --transform "s|${FOLDERNAME}|${NAME}-${VERSION}|g" ${EXCLUDE} -cjf ${ARCHIVE} ${FOLDERNAME}
cd -

mv ../${ARCHIVE} .

CHKSUM=`sha256sum ${ARCHIVE} | awk '{ print $1 }'`
SIZE=`wc -c ${ARCHIVE} | awk '{ print $1 }'`

# Print the Size info
echo
echo "Checksum for ${ARCHIVE} = ${CHKSUM}"
echo "Size for ${ARCHIVE} = ${SIZE} bytes"
echo
# Generating Release file
cat extras/package_index.json.release.template |
sed s/%%VERSION%%/${VERSION}/ |
sed s/%%FILENAME%%/${ARCHIVE}/ |
sed s/%%CHECKSUM%%/${CHKSUM}/ |
sed s/%%SIZE%%/${SIZE}/ > package_avdweb_nl_pre_release_index.json
mv *.json ..