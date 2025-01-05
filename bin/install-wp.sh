#!/usr/bin/env sh

set -e

echo "Waiting for MySQL to be ready..."
until wp db check --allow-root > /dev/null 2>&1; do
  sleep 5
done
echo "MySQL is ready."

# Fix permissions if allowed
if [ -w /var/www/html ]; then
  echo "Fixing permissions..."
  find /var/www/html -exec chown www-data:www-data {} \; || true
  chmod -R 755 /var/www/html || true
else
  echo "Skipping permission fixes (volume is read-only or not modifiable)."
fi

# Install WordPress
echo "Installing WordPress..."
wp core install \
  --title="TheNittam ORG" \
  --admin_user="thenittam" \
  --admin_password="Qwerty@123" \
  --admin_email="whois@nirmaldahal.com.np" \
  --url="http://localhost:31337/" \
  --skip-email --allow-root

# Update permalink structure
# echo "Updating permalink structure..."
# wp option update permalink_structure "/%year%/%monthnum%/%postname%/" --allow-root

# Activate plugins
PLUGINS="iwp-client social-warfare wp-advanced-search wp-file-upload"

echo "Activating plugins..."
for PLUGIN in $PLUGINS; do
  echo "Activating plugin: $PLUGIN"
  wp plugin activate "$PLUGIN" --allow-root || echo "Failed to activate $PLUGIN"
done

# Import database if dump.sql exists
if [ -f /var/www/html/dump.sql ]; then
  echo "Importing database dump..."
  wp db import /var/www/html/dump.sql --allow-root
else
  echo "No database dump found. Skipping import."
fi

echo "WordPress deployment complete."