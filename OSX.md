# OSX

This page explains how to set up the development environment on *OSX*.

## Package Management

Install [Homebrew](http://brew.sh) and then come back here.

## Xcode Command Line Tools

Run:

    xcode-select --install

## MySQL

To install MySQL, run the following:

    brew install mysql

Launch the service so it will start automatically:

    brew services start mysql

Now mysql is running, and you have a user named root with no password.

## ImageMagick
To install ImageMagick, run the following:

    brew install imagemagick --with-freetype --with-fontconfig

Make sure to add freetype and fontconfig switches, as they are needed for image captcha

## Git

To install Git, run the following:

    brew install git

## Pronto (Only for development)

The Rugged gem which is a dependency for Pronto, requires cmake:

    brew install cmake

## Redis

To install Redis, run the following:

    brew install redis

## RubyGems

RubyGems comes preinstalled. However, you might need to update it for use with the latest Bundler. To update RubyGems, run

    sudo gem update --system

## Bundler

To install Bundler, run the following:

    sudo gem install bundler

