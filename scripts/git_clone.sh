#!/bin/sh

echo "... cloning ${GIT_REPO} ..."
cd ${PROJECT_DIR}
git -c http.sslVerify=false clone ${GIT_REPO}
GIT_DIR=$(echo ${GIT_REPO##*/} | cut -d. -f1)
cd ${GIT_DIR}
. ${PROJECT_DIR}/load_venv.sh
echo "... installing requirements ..."
pip install -r requirements.txt
export PYTHONPATH=${PROJECT_DIR}/${GIT_DIR}
python ${SRC_DIR}/${APP_FILE} &
