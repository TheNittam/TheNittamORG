FROM wordpress:php7.1-apache

# Set Apache ServerName to avoid warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy custom files
COPY ./otherz /var/www/html/
COPY ./plugins /var/www/html/wp-content/plugins

# Fix permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html
