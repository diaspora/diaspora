#!/bin/bash
cd $(dirname $(readlink -e $0))/..
echo "Clone rails-i18n..."
git clone https://github.com/svenfuchs/rails-i18n.git tmp-update-rails-i18n
echo "Make sure locales directory exists..."
mkdir -p config/locales/rails-i18n
echo "Copy locale files..."
cp -Rf tmp-update-rails-i18n/rails/locale/* config/locales/rails-i18n/
echo "Delete clone..."
rm -Rf tmp-update-rails-i18n
echo "Done"
