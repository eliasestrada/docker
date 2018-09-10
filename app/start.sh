#!/bin/ash
cd /opt/streampush/app/streampush
python3 manage.py migrate
daphne -b 0.0.0.0 -p 8000 --proxy-headers streampush.asgi:application