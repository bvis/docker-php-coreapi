FROM php:5.6-apache

# ZLIB Module, required by many other modules, like memcached
RUN apt-get update \
    && apt-get install -y zlib1g-dev \
    && apt-get clean

RUN docker-php-ext-install gettext opcache mbstring mysqli

# Igbinary
RUN pecl install igbinary \
    && docker-php-ext-enable igbinary

# APCu module
RUN pecl install apcu-4.0.10 \
    && docker-php-ext-enable apcu

# Memcached module with igbinary support. The package provided by PECL does not support it
RUN apt-get install -y libmemcached-dev=1.0.18-4 \
    && pecl download memcached-2.2.0 \
    && tar xzvf memcached-2.2.0.tgz \
    && cd memcached-2.2.0 \
    && phpize \
    && ./configure --enable-memcached-igbinary --disable-memcached-sasl \
    && make \
    && make install \
    && docker-php-ext-enable memcached \
    && apt-get clean

# AMQP module (RabbitMQ)
RUN apt-get install -y librabbitmq-dev \
    && pecl install amqp \
    && docker-php-ext-enable amqp \
    && apt-get clean

#------------------------------------------------------------------------------
# Populate root file system:
#------------------------------------------------------------------------------
ADD rootfs /

# Download Browscap ini file
RUN mkdir -p /usr/local/etc/php/extra/ \
    && curl "http://browscap.org/stream?q=Full_PHP_BrowsCapINI" -o /usr/local/etc/php/extra/full_php_browscap.ini

# Setup timezone to UTC
RUN sed -i 's/^;\(date.timezone.*\)/\1 \"UTC\"/' /usr/local/etc/php/php.ini

# Remove deprecated warning
RUN sed -i 's/;always_populate_raw_post_data = -1/always_populate_raw_post_data = -1/' /usr/local/etc/php/php.ini
