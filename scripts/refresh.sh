#!/bin/sh

TIME=$(date +"%T")
echo "... $TIME refreshing apigw config ..."
cd $PROJECT_DIR
. load_venv.sh
cd $PROJECT_DIR/py_apigw_refresher
python src/refresher.py > $APIGW_CONFIG_DIR/mesos.conf
sudo /usr/local/sbin/nginx -s reload
