#!/bin/sh
set -e

alembic upgrade head
exec uvicorn main:app --proxy-headers --host 0.0.0.0 --port 80
