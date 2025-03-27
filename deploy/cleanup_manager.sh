#!/bin/bash
cd backups || exit
ls -t | sed -e '1,10d' | xargs -d '\n' rm -rf --
echo 🔄 Pulling latest changes..... | tee -a logs/deploy.log
