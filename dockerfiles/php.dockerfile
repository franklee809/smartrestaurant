FROM php:8.1.3-fpm-alpine3.15

WORKDIR /var/www/html

RUN apk update && apk add --no-cache \
    zip \
    unzip \
    dos2unix \
    supervisor \
    libpng-dev \
    libzip-dev \
    freetype-dev \
    $PHPIZE_DEPS \
    libjpeg-turbo-dev

# compile native PHP packages
RUN docker-php-ext-install \
    gd \
    pcntl \
    bcmath \
    mysqli \
    pdo_mysql

# configure packages
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# install additional packages from PECL
RUN pecl install zip && docker-php-ext-enable zip \
    && pecl install igbinary && docker-php-ext-enable igbinary \
    && yes | pecl install redis && docker-php-ext-enable redis

# copy supervisor configuration
COPY dockerfiles/supervisord.conf /etc/supervisord.conf

COPY src .

RUN chown -R www-data:www-data /var/www/html
# run supervisor

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
