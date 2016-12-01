FROM ubuntu:14.04

MAINTAINER Nicolas Potier <nicolas.potier@acseo-conseil.fr>

ENV ENVIRONMENT=docker
# Mongo PHP driver version
ENV MONGO_PHP_VERSION 1.5.5

################################################################################
# Install php and dependenceis
################################################################################
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -yq install \
        zip \
        unzip \
        vim \
        curl \
        wget \
        git \
        make \
        apache2 \
        libapache2-mod-php5 \
        php5 \
        # mysql-server \
        php5-dev \
        php5-intl \
        php5-gd \
        php5-curl \
        php5-mcrypt \
        php5-mysql \
        php-pear \
        php-apc && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini

################################################################################
# Composer Install
################################################################################

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /var/www/.composer && \
    chown -R www-data:www-data /var/www/.composer

################################################################################
# Mongo PECL extension
################################################################################

RUN pecl install mongo-$MONGO_PHP_VERSION && \
    mkdir -p /etc/php5/mods-available && \
    echo "extension=mongo.so" > /etc/php5/mods-available/mongo.ini && \
    ln -s /etc/php5/mods-available/mongo.ini /etc/php5/cli/conf.d/mongo.ini && \
    ln -s /etc/php5/mods-available/mongo.ini /etc/php5/apache2/conf.d/mongo.ini && \
    ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/mcrypt.ini && \
    ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/apache2/conf.d/mcrypt.ini

################################################################################
# Apache & PHP extensions
################################################################################

COPY ./php.ini /usr/local/etc/php/conf.d/php5-cocorico.ini

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

# Apache modules setup
RUN \
    a2dismod mpm_event && \
    a2enmod mpm_prefork && \
    a2enmod php5 && \
    a2enmod rewrite && \
    a2enmod headers && \
    a2enmod ssl  && \
    a2enmod vhost_alias

# logs should go to stdout / stderr
RUN \
    set -ex && \
    . "$APACHE_ENVVARS" && \
    ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" && \
    ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" && \
    ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"

RUN rm -f /etc/apache2/sites-enabled/000-default.conf

################################################################################
# Create and give rights to cache and logs for cocorico app
################################################################################

RUN \
    mkdir -p /var/www/html/app/cache && \
    mkdir -p /var/www/html/app/logs && \
    chown -R www-data:www-data /var/www/html/app/cache && \
    chown -R www-data:www-data /var/www/html/app/logs

################################################################################
# Clean temporary files
################################################################################

RUN \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

################################################################################
# Launch appache
################################################################################

WORKDIR /var/www/html

COPY apache2-foreground /usr/local/bin/
EXPOSE 80
CMD ["apache2-foreground"]
