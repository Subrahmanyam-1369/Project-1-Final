#!/bin/bash
cd backups || exit
ls -t | sed -e '1,10d' | xargs -d '\n' rm -rf --
