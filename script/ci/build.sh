#!/bin/sh

command="bundle exec rake --trace ci:travis:${BUILD_TYPE}"

exec xvfb-run --auto-servernum --server-num=1 --server-args="-screen 0 1280x1024x8" $command
