#!/usr/bin/env bash

####                                                             ####
#                                                                   #
#          minimal required functions to load the rest...           #
#                                                                   #
####                                                             ####


# ... let's hope nobody hijacks githubs DNS while this runs :P
D_REMOTE_BASE_URL="https://raw.github.com/diaspora/diaspora/develop/"

# ruby environment
D_REMOTE_ENV_PATH="script/env/ruby_env"

# installer files
D_INSTALL_SCRIPT="script/install.sh"
D_INSTALL_DEFAULTS_PATH="script/install/defaults"
D_INSTALL_REMOTE_VAR_READER_PATH="script/install/remote_var_reader"
D_INSTALL_PATH_SANITIZER_PATH="script/install/path_sanitizer"
D_INSTALL_FUNCTIONS_PATH="script/install/functions"
D_INSTALL_SETUP_PATH="script/install/setup"

# fetch a remote script containing functions and eval them into the local env
include_remote() {
  _remote_include=$1
  __TMP=$(curl -L $_remote_include)
  eval "$__TMP"
}


include_remote "$D_REMOTE_BASE_URL$D_INSTALL_DEFAULTS_PATH"
include_remote "$D_REMOTE_BASE_URL$D_INSTALL_REMOTE_VAR_READER_PATH"
include_remote "$D_REMOTE_BASE_URL$D_INSTALL_PATH_SANITIZER_PATH"
include_remote "$D_REMOTE_BASE_URL$D_INSTALL_FUNCTIONS_PATH"
include_remote "$D_REMOTE_BASE_URL$D_INSTALL_SETUP_PATH"

read_var_remote "ruby_version" "D_RUBY_VERSION"


####                                                             ####
#                                                                   #
#      define some overly long message strings here...              #
#                                                                   #
####                                                             ####

define RVM_MSG <<'EOT'
RVM was not found on your system (or it isn't working properly).
It is higly recommended to use it, since it's making it extremely easy
to install, manage and work with multiple ruby environments.

For more details check out https://rvm.io//
EOT


define JS_RT_MSG <<'EOT'
This script was unable to find a JavaScript runtime compatible to ExecJS on
your system. We recommend you install either Node.js or TheRubyRacer, since
those have been proven to work.

Node.js      -- http://nodejs.org/
TheRubyRacer -- https://github.com/cowboyd/therubyracer

For more information on ExecJS, visit
-- https://github.com/sstephenson/execjs
EOT

define DATABASE_CHK_MSG << 'EOT'
You can now check the generated database config file in './config/database.yml'
and see if the specified values are correct.

Please make sure the database server is started and the credentials you
specified are working. This script will populate the database in a later step.

EOT

define WELCOME_MSG <<'EOT'
#####################################################################

DIASPORA* INSTALL SCRIPT

----

This script will guide you through the basic steps
to get a DEVELOPMENT setup of Diaspora* up and running

For a PRODUCTION installation, please do *not* use this script!
Follow the guide in our wiki, instead:
-- https://github.com/diaspora/diaspora/wiki/Installation-Guides

#####################################################################

EOT

define GOODBYE_MSG <<EOT
#####################################################################

It worked! :)

Now, you should have a look at

  - config/database.yml      and
  - config/diaspora.yml

and change them to your liking. Then you should be able to
start Diaspora* in development mode with:

    \`rails s\`


For further information read the wiki at $D_WIKI_URL
or join us on IRC $D_IRC_URL

EOT


####                                                             ####
#                                                                   #
#                              do it!                               #
#                                                                   #
####                                                             ####

diaspora_setup
