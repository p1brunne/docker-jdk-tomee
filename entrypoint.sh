#!/bin/bash
set -e

until netcat -z -w 2 db 3306; do echo "wait for db"; sleep 1; done

exec "$@"


