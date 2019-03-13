#!/bin/ksh

function get_pass {
	stty -echo
	IFS= read -r resp?"Password to check: "
	stty echo
	echo >&2
	echo $resp
	return 0
}

set -x
tf=`mktemp tmp.XXXXXX` || exit 1
get_pass >$tf
cat $tf
hash=`sha1 -q $tf`
key=`echo $hash | cut -c1-5`
echo "Checking key $key..."
url="https://api.pwnedpasswords.com/range"
curl -k -v \
-w "%{http_code}" \
-A "Pwnage-Cli-Checker v0.1" \
-o $tf \
-H "api-version: 2" \
$url/$key

cat $tf

rm -f $tf

