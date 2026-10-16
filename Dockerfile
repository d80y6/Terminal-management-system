# Use official PHP 8.4 FPM image
FROM php:8.4-fpm

# Install system dependencies, Node.js, npm, and PostgreSQL development libraries
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
    nodejs \
    npm \
    && docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files into the container
COPY . /var/www/html

# Copy custom Nginx configuration
COPY docker/nginx.conf /etc/nginx/sites-available/default

# Install PHP dependencies (production optimized)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Install frontend dependencies and build Vite assets
RUN npm install
RUN npm run build

# Set correct file permissions for Laravel storage and cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80 for web traffic
EXPOSE 80

# Start script: clear cache, cache fresh config with environment variables, migrate, and start services
CMD php artisan config:cache && \
    php artisan route:cache && \
    php artisan migrate --force && \
    service nginx start && \
    php-fpm
