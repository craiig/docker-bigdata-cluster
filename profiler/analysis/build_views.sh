#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for v in $(find $DIR/views -iname "*.sql"); do
	echo loading $v
	$DIR/psql.sh < $v
done
