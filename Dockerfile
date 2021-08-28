FROM php:7.4-fpm

RUN apt update && apt install -y \
        unzip \
        supervisor \
        nginx \
        libcurl4-openssl-dev \
        libpq-dev \
        libonig-dev \
        libmcrypt-dev \
        zlib1g-dev \
        libmemcached-dev \
        libzip-dev \
      && pecl install \
        mcrypt \
        igbinary \
        memcached \
        redis \
        grpc \
      && docker-php-ext-install \
        curl \
        pdo \
        pdo_pgsql \
        pdo_mysql \
        mbstring \
        mysqli \
        zip \
      && docker-php-ext-enable \
        mcrypt \
        igbinary \
        memcached \
        opcache \
        redis \
        grpc

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
      && php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
      && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

COPY conf/nginx.conf /etc/nginx/sites-enabled/default
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY conf/php-fpm-www.conf /usr/local/etc/php-fpm.d/www.conf
COPY conf/php-fpm-docker.conf /usr/local/etc/php-fpm.d/docker.conf

WORKDIR /app

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
