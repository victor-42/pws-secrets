# ENVVVV
FROM debian:latest AS build-env

# install all needed stuff
RUN apt-get update
RUN apt-get install -y curl git unzip

# define variables
ARG FLUTTER_SDK=/usr/local/flutter
ARG FLUTTER_VERSION=3.16.2
ARG APP=/app/

#clone flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK
# change dir to current flutter folder and make a checkout to the specific version
RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

# setup the flutter path as an enviromental variable
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

# Start to run Flutter commands
# doctor to see if all was installes ok
RUN flutter doctor -v

# create folder to copy source code
RUN mkdir $APP
# copy source code to folder
COPY . $APP
# stup new folder as the working directory
WORKDIR $APP/app

# Run build: 1 - clean, 2 - pub get, 3 - build web
RUN flutter clean
RUN flutter pub get
RUN flutter build web

# once heare the app will be compiled and ready to deploy


# Use the official Python base image
FROM python:3.11

# Set the working directory
WORKDIR /app


# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install system dependencies
RUN apt-get update && apt-get install -y nginx gunicorn cron supervisor

# Install the required packages using pip
COPY backend/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn

# Set up the nginx server and flutter web
COPY --from=build-env /app/app/build/web /app/build/flutter_web
COPY --chown=nginx:nginx ./secrets_build/nginx.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/default

COPY ./secrets_build/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY . .

COPY --from=build-env /app/app/assets/logo /app/build/flutter_web/assets/logo

COPY secrets_build/cleanup_cron /etc/cron.d/cleanup_cron
RUN chmod 0644 /etc/cron.d/cleanup_cron
RUN crontab /etc/cron.d/cleanup_cron

# Copy the Django project to the container
WORKDIR /app/backend

ENV DJANGO_SECRET_KEY ajdfaskljfioadsfjadoijfda
ENV DJANGO_ALLOWED_HOST test.de
ENV DJANGO_DEBUG True
ENV DJANGO_SETTINGS_MODULE configuration.settings

ENV SERVER_NAME 0.0.0.0

# Expose the ports
EXPOSE 80

# Run Migration and collect static files
RUN python manage.py migrate --noinput
RUN python manage.py collectstatic --noinput

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
