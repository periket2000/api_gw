#!/bin/sh
if [ "${PROJECT_DIR}X" != "X" ]; then
    echo "${GIT_REPO}" > ${PROJECT_DIR}/git.txt
else 
    echo "No environment set" > /tmp/git.txt
fi

# dnsmasq is required in order to nginx user /etc/hosts as resolver
sudo /usr/sbin/dnsmasq -d &
${PROJECT_DIR}/tests.sh
${PROJECT_DIR}/virtualenv.sh
${PROJECT_DIR}/api_gw.sh
${PROJECT_DIR}/run-parts.sh &
${PROJECT_DIR}/git_clone.sh
while true; do sleep 1000; done
