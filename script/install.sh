#!/usr/bin/env bash

###
# MAKE ME BETTER
###

: '
see https://github.com/jamiew/git-friendly for more ideas

maybe this should be two files
one which includes cloning diaspora/diaspora, and one that assumes you already cloned it yourself
maybe one script just calls another?


other ideas what we could do

 1. check that you have ruby installed, if not, point to wiki page and exit
 2. check to see if we need sudo (generally, if it is a system ruby you need sudo, which you can check
    if which ruby is /usr/bin/ruby, or does not have rvm in the path)
 3. check if you have bundle installed and install it, and install with/without sudo if you need it

 check if you have mysql and/or postgres installed, point to wiki page if neither is found.
 (maybe even switch database.yml if this is the case?)

 make it work if you have just cloned diapsora and want a quick setup, or
 support magic install, like this http://docs.meteor.com/#quickstart
'

####                                                             ####
#                                                                   #
#                           DEFAULT VARS                            #
#                                                                   #
####                                                             ####

# required programs
declare -A BINARIES
BINARIES["git"]="git"
BINARIES["ruby"]="ruby"
BINARIES["rubygems"]="gem"
BINARIES["bundler"]="bundle"
BINARIES["sed"]="sed"
BINARIES["mktemp"]="mktemp"

D_GIT_CLONE_PATH="/srv/diaspora"     # path for diaspora

D_REMOTE_REPO_URL="https://github.com/diaspora/diaspora.git"

D_INSTALL_SCRIPT_URL="https://raw.github.com/diaspora/diaspora/master/script/install.sh"

D_WIKI_URL="https://github.com/diaspora/diaspora/wiki"

D_IRC_URL="irc://freenode.net/diaspora"

D_DB="mysql"

D_DB_CONFIG_FILE="config/database.yml"

D_DB_HOST="localhost"

D_DB_USER="diaspora"

D_DB_PASS="diaspora"

# TODO: read this from ./script/env/ruby_env
D_RUBY_VERSION="1.9.3-p194"

####                        INTERNAL VARS                        ####

RVM_DETECTED=false
JS_RUNTIME_DETECTED=false
ONE_UP="\e[1A"

####                                                             ####
#                                                                   #
#                          FUNCTIONS, etc.                          #
#                                                                   #
####                                                             ####

#... could be put in a separate file and sourced here

# heredoc for variables - very readable, http://stackoverflow.com/a/8088167
# use like this:
# define VAR <<'EOF'
# somecontent
# EOF
define(){ IFS='\n' read -r -d '' ${1}; }

# add padding to the left of a given string to
# fill to a given amount of characters with a 
# given char or space
# example:
#   lpad 7 "test" "-"
lpad() {
  LEN=$1
  TXT=$2
  CHR=$3
  PAD=""

  L_PAD=$(($LEN - ${#TXT}))
  if [ $L_PAD -ne 0 ] ; then
    PAD=$(printf "%*s" ${L_PAD} " ")
  fi
  if [ ${#CHR} -ne 0 ] ; then
    PAD=$(printf "$PAD" | tr " " "$CHR")
  fi
  PAD="${PAD}${TXT}"

  printf "%s" "$PAD"
}

# log function
# prints a given message with the given log level to STDOUT
logf() {
  MSG=$1
  LVL=$2
  L_LEN=7

  if [ ${#LVL} -ne 0 ] ; then
    LVL="[$(lpad $(($L_LEN-2)) $LVL " ")]"
  else
    LVL=$(lpad $L_LEN "" "-")
  fi

  printf "%s -- %s\\n" "$LVL" "$MSG"
}

# short functions for various log levels
log_err() {
  logf "$1" "error"
}

log_wrn() {
  logf "$1" "warn"
}

log_dbg() {
  logf "$1" "debug"
}

log_inf() {
  logf "$1" "info"
}

# run a command or print the error
run_or_error() {
  eval "$1"
  if [ $? -ne 0 ]; then
    error "executing '$1' failed."
  fi
}

# nicely output error messages and quit
error() {
  log_err "$1"
  logf "have a look at our wiki: $D_WIKI_URL"
  logf "or join us on IRC: $D_IRC_URL"
  exit 1
}

# check for functions
fn_exists() {
  type -t $1 | grep -q 'function'
}

# shell interactive or not
interactive_check() {
  fd=0 #stdin
  if [[ -t "$fd" || -p /dev/stdin ]]; then
    # all is well
    printf "\n"
  else
    # non-interactive
    TMPFILE=`mktemp`
    curl -s -o "$TMPFILE" "$D_INSTALL_SCRIPT_URL"
    chmod +x "$TMPFILE"
    exec 0< /dev/tty
    bash -i "$TMPFILE"
    rm "$TMPFILE"
    exit 0
  fi
}

# check if this script is run as root
root_check() {
  if [ `id -u` -eq 0 ] ; then
    error "don't run this script as root!"
  fi
}

# check if all necessary binaries are available
binaries_check() {
  for exe in "${!BINARIES[@]}"; do
    LOG_MSG="checking for $exe... "
    log_inf "$LOG_MSG"

    EXE_PATH=$(which "${BINARIES[$exe]}")
    if [ $? -ne 0 ]; then
      error "you are missing the '${BINARIES[$exe]}' command, please install '$exe'";
    else
      printf "$ONE_UP"
      log_inf "$LOG_MSG  found"
    fi
  done
  printf "\n"
}

# check for rvm
define RVM_MSG <<'EOT'
RVM was not found on your system (or it isn't working properly).
It is higly recommended to use it, since it's making it extremely easy
to install, manage and work with multiple ruby environments.

For more details check out https://rvm.io//
EOT
rvm_check() {
  LOG_MSG="checking for rvm... "
  log_inf "$LOG_MSG"

  fn_exists rvm
  if [ $? -eq 0 ] ; then
    RVM_DETECTED=true

  # seems we don't have it loaded, try to do so
  elif [ -s "$HOME/.rvm/scripts/rvm" ] ; then
    source "$HOME/.rvm/scripts/rvm" >/dev/null 2>&1
    RVM_DETECTED=true
  elif [ -s "/usr/local/rvm/scripts/rvm" ] ; then
    source "/usr/local/rvm/scripts/rvm" >/dev/null 2>&1
    RVM_DETECTED=true
  fi

  if $RVM_DETECTED ; then
    printf "$ONE_UP"
    log_inf "$LOG_MSG  found"
  else
    log_wrn "not found"
    logf "$RVM_MSG"
    read -p "Press [Enter] to continue without RVM or abort this script and install RVM..."
  fi
  printf "\n"
}

# prepare ruby with rvm
install_or_use_ruby() {
  if ! $RVM_DETECTED ; then
    return
  fi

  # make sure we have the correct ruby version available
  LOG_MSG="checking your ruby version... "
  log_inf "$LOG_MSG"

  rvm use $D_RUBY_VERSION >/dev/null 2>&1
  if [ $? -ne 0 ] ; then
    log_wrn "not ok"
    rvm --force install $D_RUBY_VERSION
  else
    printf "$ONE_UP"
    log_inf "$LOG_MSG  ok"
  fi

  printf "\n"
}

# trust and load rvmrc
# do this in a directory that has a .rvmrc, only :)
load_rvmrc() {
  if ! $RVM_DETECTED || [[ ! -s ".rvmrc" ]] ; then
    return
  fi

  # trust rvmrc
  rvm rvmrc is_trusted
  if [ $? -ne 0 ] ; then
    rvm rvmrc trust
  fi

  # load .rvmrc
  LOG_MSG="loading .rvmrc ... "
  log_inf "$LOG_MSG"

  . ".rvmrc"
  #rvm rvmrc load
  if [ $? -eq 0 ] ; then
    printf "$ONE_UP"
    log_inf "$LOG_MSG  ok"
  else
    log_wrn "not ok"
  fi
  printf "\n"
}

# rvm doesn't need sudo, otherwise we do have to use it :(
rvm_or_sudo() {
  if $RVM_DETECTED ; then
    run_or_error "$1"
  else
    eval "$1"
    if [ $? -ne 0 ] ; then
      log_wrn "running '$1' didn't succeed, trying again with sudo..."
      run_or_error "sudo $1"
    fi
  fi
}

# we need a valid js runtime...
define JS_RT_MSG <<'EOT'
This script was unable to find a JavaScript runtime compatible to ExecJS on
your system. We recommend you install either Node.js or TheRubyRacer, since
those have been proven to work.

Node.js      -- http://nodejs.org/
TheRubyRacer -- https://github.com/cowboyd/therubyracer

For more information on ExecJS, visit
-- https://github.com/sstephenson/execjs
EOT
js_runtime_check() {
  LOG_MSG="checking for a JavaScript runtime... "
  log_inf "$LOG_MSG"

  # Node.js
  which node >/dev/null 2>&1
  if [ $? -eq 0 ] ; then
    JS_RUNTIME_DETECTED=true
  fi

  # TheRubyRacer
  (printf "require 'v8'" | ruby) >/dev/null 2>&1
  if [ $? -eq 0 ] ; then
    JS_RUNTIME_DETECTED=true
  fi

  ##
  # add a check for your favourite js runtime here...
  ##

  if $JS_RUNTIME_DETECTED ; then
    printf "$ONE_UP"
    log_inf "$LOG_MSG  found"
  else
    log_err "not ok"
    printf "$JS_RT_MSG"
    error "can't continue without a JS runtime"
  fi
  printf "\n"
}

# make ourselves comfy
prepare_install_env() {
  install_or_use_ruby
  load_rvmrc
  js_runtime_check

  log_inf "making sure the 'bundler' gem is installed"
  rvm_or_sudo "gem install bundler"
}

# do some sanity checking
sane_environment_check() {
  binaries_check
  rvm_check
}

# find or set up a working git environment
git_stuff_check() {
  printf "Where would you like to put the git clone, or, where is your existing git clone?\n"
  printf "(please use a full path, not '~' or '.')\n"
  read -e -p "-> " D_GIT_CLONE_PATH
  printf "\n"

  test -d "$D_GIT_CLONE_PATH" \
    && cd "$D_GIT_CLONE_PATH" \
    && git status # folder exists? go there. is a good git clone?
  if [ $? -ne 0 ]; then
    # not a git repo, create it?
    printf "the folder you specified does not exist or doesn't contain a git repo\n"
    read -p "Press [Enter] to create it and contine... "
    run_or_error "mkdir -p -v \"$D_GIT_CLONE_PATH\""  # only if it doesn't exist
    run_or_error "git clone \"$D_REMOTE_REPO_URL\" \"$D_GIT_CLONE_PATH\""
  else
    run_or_error "git checkout master"
    run_or_error "git pull"
  fi
  printf "\n"
}

# handle database decision
database_question() {
  printf "Which database type are you using? [1|2]\n"
  select choice in "MySQL" "PgSQL"; do
    case $choice in
      MySQL )
        D_DB="mysql"
        # we're done, mysql is default
        break
        ;;
      PgSQL )
        D_DB="postgres"
        # replace default with postgres
        run_or_error "sed -i'' -e 's/\(<<: \*mysql\)/#\1/g' \"$D_DB_CONFIG_FILE\""
        run_or_error "sed -i'' -e 's/\(#\(<<: \*postgres\)\)/\2/g' \"$D_DB_CONFIG_FILE\""
        break
        ;;
    esac
  done
}

# ask for database credentials
database_credentials() {
  read -e -p "DB hostname: " D_DB_HOST
  read -e -p "DB username: " D_DB_USER
  read -e -p "DB password: " D_DB_PASS

  run_or_error "sed -i'' -e \"s/\(host:\)[^\n]*/\1 $D_DB_HOST/g\" \"$D_DB_CONFIG_FILE\""
  run_or_error "sed -i'' -e \"s/\(username:\)[^\n]*/\1 $D_DB_USER/g\" \"$D_DB_CONFIG_FILE\""
  run_or_error "sed -i'' -e \"s/\(password:\)[^\n]*/\1 $D_DB_PASS/g\" \"$D_DB_CONFIG_FILE\""

  printf "\n"
}

# setup database
# (assume we are in the Diaspora directory)
define DATABASE_CHK_MSG << 'EOT'
you can now check the generated database config file in './config/database.yml'
and see if the specified values are correct.

EOT
database_setup() {
  log_inf "Database setup"
  run_or_error "cp config/database.yml.example \"$D_DB_CONFIG_FILE\""
  database_question
  database_credentials

  printf "$DATABASE_CHK_MSG"
  read -p "Press [Enter] to continue... "

  printf "\n"
}

# install all the gems with bundler
# (assume we are in the Diaspora directory)
prepare_gem_bundle() {
  log_inf "installing all required gems..."
  rvm_or_sudo "bundle install"
  printf "\n"
}


####                                                             ####
#                                                                   #
#                              START                                #
#                                                                   #
####                                                             ####

#interactive_check
root_check


# display a nice welcome message
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
printf "$WELCOME_MSG"
read -p "Press [Enter] to continue... "


# check if we have everything we need
sane_environment_check


# check git stuff and pull if necessary
git_stuff_check


# goto working directory
run_or_error "cd \"$D_GIT_CLONE_PATH\""
prepare_install_env


# configure database setup
database_setup


# diaspora config
log_inf "copying diaspora.yml.example to diaspora.yml"
run_or_error "cp config/diaspora.yml.example config/diaspora.yml"
printf "\n"


# bundle gems
prepare_gem_bundle


log_inf "creating the default database specified in config/database.yml. please wait..."
run_or_error "bundle exec rake db:schema:load_if_ruby --trace"
printf "\n"

define GOODBYE_MSG <<EOT
#####################################################################

It worked! :)

Now, you should have a look at

  - config/database.yml      and
  - config/diaspora.yml

and change them to your liking. Then you should be able to
start Diaspora* in development mode with:

    `rails s`


For further information read the wiki at $D_WIKI_URL
or join us on IRC $D_IRC_URL

EOT
printf "$GOODBYE_MSG"


exit 0

