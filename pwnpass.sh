#!/bin/sh

# Pwnpass CLI Checking
#
# Copyright (c) 2019 Michael Graves <mg@brainfat.net>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

url="https://api.pwnedpasswords.com/range"

tf=`mktemp tmp.XXXXXX` || exit 1
set -o noglob
stty -echo
IFS= read -r resp?"Password to check: "
stty echo
set +o noglob
echo >&2
echo -n $resp >$tf
hash=`sha1 -q $tf`
key=`echo $hash | cut -c1-5`
base=`echo $hash | cut -c6-`
echo "Checking key $key\n"
rc=`curl -s -k \
  -H "api-version: 2" \
  -w "%{http_code}" \
  -A "Pwnage-Cli-Checker v0.1" \
  -o $tf \
  $url/$key`
if [ "$rc" != "200" ]; then
	echo "Error connecting to site. rc=$rc"
	cat $tf
	rm -f $tf
	exit 1
fi
#echo "Base: $base"
found=`cat $tf | grep -i $base`
if [ -z "$found" ]; then
	echo "Password not found."
else
	c=`echo $found | cut -f2 -d: | tr -d ""`
	echo "Password found. $c time(s)"
fi

rm -f $tf
exit 0
