#!/bin/bash
set -e

alembic upgrade head
uvicorn main:app --proxy-headers --host 0.0.0.0 --port 80
