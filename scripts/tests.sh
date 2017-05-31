#!/bin/sh
echo --- Tests ---

echo -n "Git installed... "
git --version > /dev/null
[ "$?" -ne 0 ] && echo nope && exit 1
echo ok

echo -n "Python installed... "
python3 --version > /dev/null
[ "$?" -ne 0 ] && echo nope && exit 1
echo ok

echo -n "Pip installed... "
pip --version > /dev/null
[ "$?" -ne 0 ] && echo nope && exit 1
echo ok

echo -n "Nginx installed... "
/usr/local/sbin/nginx -V > /dev/null
[ "$?" -ne 0 ] && echo nope && exit 1
echo ok
