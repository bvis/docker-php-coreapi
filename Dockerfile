FROM php:5.6-apache

# ZLIB Module, required by many other modules, like memcached
RUN apt-get update \
    && apt-get install -y zlib1g-dev \
    && apt-get clean

# Basic modules
RUN docker-php-ext-install gettext opcache mbstring mysqli bcmath opcache \
# Igbinary module
    && pecl install igbinary \
    && docker-php-ext-enable igbinary \
# APCu module
    && pecl install apcu-4.0.10 \
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
    && apt-get clean

#------------------------------------------------------------------------------
# Populate root file system:
# - php.ini
# - Modules defaults configuration
#------------------------------------------------------------------------------
ADD rootfs /

# Extra folder for storing SQL Errors. TODO: Change this to another log strategy.
RUN mkdir -p /var/log/sql/ && chmod 0777 /var/log/sql/

# Download Browscap ini file
RUN mkdir -p /usr/local/etc/php/extra/ \
    && curl "http://browscap.org/stream?q=Full_PHP_BrowsCapINI" -o /usr/local/etc/php/extra/full_php_browscap.ini
