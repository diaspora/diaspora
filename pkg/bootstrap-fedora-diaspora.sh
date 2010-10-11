#!/bin/bash

export DIASPORADIR=`pwd`

echo "####"
echo "Installing build deps ..."
echo "####"
sleep 3
su -c "yum install git bison svn autoconf sqlite-devel gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel ImageMagick git rubygems libxslt libxslt-devel libxml2 libxml2-devel openssl-devel"

echo "####"
echo "Installing RVM ..."
echo "####"
sleep 3

mkdir -p ~/.rvm/src/ && cd ~/.rvm/src && rm -rf ./rvm/ && git clone --depth 1 git://github.com/wayneeseguin/rvm.git && cd rvm && ./install

echo "####"
echo "Installing RVM into bashrc and sourcing bash ..."
echo "####"
sleep 3

if [[ `grep -l "rvm/scripts/rvm" $HOME/.bashrc | wc -l` -eq 0 ]]; then
  echo 'if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then source "$HOME/.rvm/scripts/rvm" ; fi' >> $HOME/.bashrc
fi
source $HOME/.bashrc

echo "####"
echo "Installing ruby (will take forever) ..."
echo "####"
sleep 3

rvm install ruby-1.8.7-p302
rvm --default ruby-1.8.7

echo "####"
echo "Installing bundler ..."
echo "####"
sleep 3

gem install bundler

echo "####"
echo "Installing deps with bundle ..."
echo "####"
sleep 3

pushd $DIASPORADIR && bundle install && popd
