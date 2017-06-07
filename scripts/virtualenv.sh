#!/bin/sh

echo "... setting up virtualenv ..."
cd ${PROJECT_DIR}
virtualenv -p /usr/bin/python python-env
. ${PROJECT_DIR}/python-env/bin/activate
