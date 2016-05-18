FROM php:5.6-apache

MAINTAINER Basilio Vera <basilio.vera@softonic.com>

# ZLIB Module, required by many other modules, like memcached
RUN apt-get update \
    && apt-get install -y zlib1g-dev \
    && apt-get clean \
# Basic modules
    && docker-php-ext-install pcntl sockets bcmath mbstring opcache mysqli gettext \
# Igbinary module
    && pecl install igbinary \
    && docker-php-ext-enable igbinary \
# APCu module
    && pecl install apcu-4.0.11 \
    && docker-php-ext-enable apcu \
# Memcached module with igbinary support. The package provided by PECL does not support it
    && apt-get install -y libmemcached-dev=1.0.18-4 \
    && pecl download memcached-2.2.0 \
    && tar xzvf memcached-2.2.0.tgz \
    && cd memcached-2.2.0 \
    && phpize \
    && ./configure --enable-memcached-igbinary --disable-memcached-sasl \
    && make \
    && make install \
    && docker-php-ext-enable memcached \
    && apt-get clean \
    && rm -rf /var/www/html/*

#------------------------------------------------------------------------------
# Populate root file system:
# - php.ini
# - Modules defaults configuration
#------------------------------------------------------------------------------
ADD rootfs /

# Add Softonic CA certificate
RUN echo "softonic_ca.pem" >> /etc/ca-certificates.conf \
    && update-ca-certificates \
# Extra folder for storing SQL Errors. TODO: Change this to another log strategy.
    && mkdir -p /var/log/sql/ && chmod 0777 /var/log/sql/ \
# Download Browscap ini file
    && mkdir -p /usr/local/etc/php/extra/ \
    && curl "http://browscap.org/stream?q=Full_PHP_BrowsCapINI" -o /usr/local/etc/php/extra/full_php_browscap.ini \
# Allow apache mod_status access form internal networks, needed by the apache exporter
    && sed -i 's/#Require ip 192.0.2.0\/24/Require ip 10.0.0.0\/8 172.16.0.0\/12 192.168.0.0\/16/' /etc/apache2/mods-enabled/status.conf
