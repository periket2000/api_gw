#!/bin/sh

TIME=$(date +"%T")
echo "... $TIME refreshing apigw config ..."
cd $PROJECT_DIR
. load_venv.sh
cd $PROJECT_DIR/py_apigw_refresher

if [[ "x$SCHEDULER" == "x" ]]; then
    exit 0
fi


if [[ "x$SCHEDULER" == "xaurora" ]]; then
    python src/aurora_refresher.py > /tmp/config
fi

if [[ "x$SCHEDULER" == "xmarathon" ]]; then
    python src/refresher.py > /tmp/config
fi

if [ -s /tmp/config ]
then
    cat /tmp/config > $APIGW_CONFIG_DIR/mesos.conf
    sudo /usr/local/sbin/nginx -s reload
fi
