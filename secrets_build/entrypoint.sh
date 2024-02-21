#!/bin/sh

# Start nginx
nginx -g "daemon off;" &

exec gunicorn configuration.wsgi:application --bind 0.0.0.0:8000 --workers 4
