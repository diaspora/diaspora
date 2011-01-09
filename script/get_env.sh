#!/bin/bash
#
# Get value from AppConfig
#
# Usage get_env [key ...]

path=$( readlink -fn $0) && cd $(dirname $path)/.. || exit 2

size=0
size=$( wc tmp/environment 2>/dev/null | awk '{print $1}') || :
if [[ "$size" = "0"  || tmp/environment -ot config/app_config.yml ]]
then
    ruby > tmp/environment << 'EOT'
        require File.join('config', 'environment.rb')
        AppConfig.config_vars.each { |key, value| 
           puts key.to_s + "\t" + value.to_s 
        }
        puts "pod_uri.host\t" + AppConfig[:pod_uri].host.to_s
        puts "pod_uri.path\t" + AppConfig[:pod_uri].path.to_s
        puts "pod_uri.port\t" + AppConfig[:pod_uri].port.to_s
EOT
fi

for key in $@; do
    awk -v key=$key '{ if ($1 == key ) print $2 }' < tmp/environment
done
