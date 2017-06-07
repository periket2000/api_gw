#!/bin/sh
if [ "${PROJECT_DIR}X" != "X" ]; then
    echo "${GIT_REPO}" > ${PROJECT_DIR}/git.txt
else 
    echo "No environment set" > /tmp/git.txt
fi

${PROJECT_DIR}/tests.sh
${PROJECT_DIR}/virtualenv.sh
${PROJECT_DIR}/api_gw.sh
${PROJECT_DIR}/run-parts.sh &
${PROJECT_DIR}/git_clone.sh
while true; do sleep 1000; done
