#!/bin/sh
if [ "${PROJECT_DIR}X" != "X" ]; then
    echo "${GIT_REPO}" > ${PROJECT_DIR}/git.txt
else 
    echo "No environment set" > /tmp/git.txt
fi

# dnsmasq is required in order to nginx user /etc/hosts as resolver
sudo /usr/sbin/dnsmasq -d &
/usr/bin/redis-server && redis-cli config set save "" &
${PROJECT_DIR}/tests.sh
${PROJECT_DIR}/virtualenv.sh
${PROJECT_DIR}/api_gw.sh
${PROJECT_DIR}/run-parts.sh &
${PROJECT_DIR}/git_clone.sh

# this line avoid the container to die properly when aurora calls runner.kill()
# while true; do sleep 1000; done
