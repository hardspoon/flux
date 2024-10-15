# Use an official PHP image as a base
FROM php:8.0-cli

# Working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libssl-dev \
    libgmp-dev \
    mariadb-client \
    nodejs \
    npm \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxi6 \
    libxtst6 \
    libxrandr2 \
    libgconf-2-4 \
    wget \
    lsb-release \
    fonts-liberation \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    ca-certificates \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgtk-3-0 \
    libnss3 \
    libappindicator1 \
    xdg-utils

# Install Node.js and Puppeteer
RUN npm install --global --unsafe-perm puppeteer \
    && chmod -R o+rx /usr/lib/node_modules/puppeteer/.local-chromium

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy existing application code to the container
COPY . .

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Set correct permissions for the storage and bootstrap/cache directories
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

# Generate application key and migrate the database
RUN php artisan key:generate
RUN php artisan migrate --force

# Install frontend dependencies and compile assets for production
RUN yarn install
RUN npm run prod

# Expose the web server port
EXPOSE 8000

# Start the Laravel PHP development server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
