# Use official PHP 8.3 image with necessary extensions for Laravel and PostgreSQL
FROM php:8.3-fpm

# Install system dependencies and PostgreSQL drivers
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zip \
    unzip \
    nginx \
    && docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy existing application directory contents
COPY . /var/www/html

# Copy custom Nginx configuration
COPY docker/nginx.conf /etc/nginx/sites-available/default

# Install PHP dependencies via Composer (excluding dev dependencies for production)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Set correct permissions for storage and cache directories
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80 for web traffic
EXPOSE 80

# Start Nginx and PHP-FPM via startup script
CMD service nginx start && php-fpm