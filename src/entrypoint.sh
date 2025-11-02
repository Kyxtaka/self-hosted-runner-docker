#!/bin/bash
set -e

#cd /home/runner
#echo "finf run.sh"
#find / -name "run.sh" 2>/dev/null
#echo "find .runner"
#find / -name ".runner" 2>/dev/null
#echo "find config"
#find / -name "config.sh" 2>/dev/null
# ⚡ Configurer le runner au runtime avec token fourni via variable d'environnement

if [ -f .runner ]; then
    echo "Removing existing runner session..."
    ./config.sh remove --token $RUNNER_TOKEN || true
fi


if [ ! -f ".runner" ]; then
  echo "TU TE LANCE OU PAS"
  ./config.sh --url "${REPO_URL}" --token "${RUNNER_TOKEN}" --unattended --replace
fi


#echo "test"
#exec ./config.sh --url "${REPO_URL}" --token "${RUNNER_TOKEN}" --unattended --replace
echo "exec run.sh"
exec ./run.sh
