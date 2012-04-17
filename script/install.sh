#!/bin/bash

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

BINARIES="git ruby gem bundle sed"       # required programs

D_GIT_CLONE_PATH="/srv/diaspora"     # path for diaspora

D_REMOTE_REPO_URL="git://github.com/diaspora/diaspora.git"

D_WIKI_URL="https://github.com/diaspora/diaspora/wiki"

D_IRC_URL="irc://freenode.net/diaspora"

D_DB="mysql"

D_DB_CONFIG_FILE="config/database.yml"

D_DB_HOST="localhost"

D_DB_USER="diaspora"

D_DB_PASS="diaspora"

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

# expand aliases in this script
shopt -s expand_aliases

# alias echo to alway print \newlines
alias echo='echo -e'

# nicely output error messages and quit
error() {
  echo "\n"
  echo "[ERROR] -- $1"
  echo "        --"
  echo "        -- have a look at our wiki: $D_WIKI_URL"
  echo "        -- or join us on IRC: $D_IRC_URL"
  exit 1
}

# check if all necessary binaries are available
binaries_check() {
  for exe in $BINARIES; do
    echo -n "checking for $exe... " 
    which "$exe"
    if [ $? -gt 0 ]; then
      error "you are missing $exe";
    fi
  done
  echo ""
}

# check for rvm
define RVM_MSG <<'EOT'
RVM was not found on your system (or it isn't working properly).
It is higly recommended to use it, since it's making it extremely easy
to install, manage and work with multiple ruby environments.

For more details check out https://rvm.io//
EOT
rvm_check() {
  echo "checking for rvm..."
  rvm >/dev/null 2>&1
  if [ $? -gt 0 ]; then
    echo "$RVM_MSG"
    read -p "Press [Enter] to continue without RVM or abort this script and install RVM"
  fi
  echo ""
}

# do some sanity checking
sane_environment_check() {
  binaries_check
  rvm_check
}

# find or set up a working git environment
git_stuff_check() {
  echo "Where would you like to put the git clone?"
  echo "(or, where is your existing git clone)?"
  read -e -p "-> " D_GIT_CLONE_PATH
  echo ""

  test -d "$D_GIT_CLONE_PATH" \
    && cd "$D_GIT_CLONE_PATH" \
    && git status # folder exists? go there. is a good git clone?
  if [ $? -gt 0 ]; then
    mkdir "$D_GIT_CLONE_PATH" # only if it doesn't exist
    # not a git repo, create it?
    echo "the folder you specified does not contain a git repo"
    read -p "Press [Enter] to create it... "
    git clone "$D_REMOTE_REPO_URL" "$D_GIT_CLONE_PATH"
  else
    git checkout master
    git pull
  fi
  echo ""
}

# handle database decision
database_question() {
  echo "Which database type are you using?"
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
        sed -i'' -r 's/(<<: \*mysql)/#\1/g' $D_DB_CONFIG_FILE
        sed -i'' -r 's/(#(<<: \*postgres))/\2/g' $D_DB_CONFIG_FILE
        break
        ;;
    esac
  done
}

# ask for database credentials
database_credentials() {
  read -e -p "hostname: " D_DB_HOST
  read -e -p "username: " D_DB_USER
  read -e -p "password: " D_DB_PASS

  sed -i'' -r "s/(host:)[^\n]*/\1 $D_DB_HOST/g" $D_DB_CONFIG_FILE
  sed -i'' -r "s/(username:)[^\n]*/\1 $D_DB_USER/g" $D_DB_CONFIG_FILE
  sed -i'' -r "s/(password:)[^\n]*/\1 $D_DB_PASS/g" $D_DB_CONFIG_FILE
}

# setup database
# (assume we are in the Diaspora directory)
database_setup() {
  echo "Database setup"
  cp config/database.yml.example config/database.yml
  database_question
  database_credentials
  echo ""
}



####                                                             ####
#                                                                   #
#                              START                                #
#                                                                   #
####                                                             ####

# display a nice welcome message
define WELCOME_MSG <<'EOT'
#####################################################################
DIASPORA* INSTALL SCRIPT

This script will guide you through the basic steps
to get a copy of Diaspora* up and running
#####################################################################

EOT
echo "$WELCOME_MSG"


# check if we have everything we need
sane_environment_check


# check git stuff and pull if necessary
git_stuff_check


# goto working directory
cd "$D_GIT_CLONE_PATH"


# configure database setup
database_setup


echo "copying application.yml.example to application.yml"
cp config/application.yml.example config/application.yml
echo ""

echo "bundling..."
bundle install
echo ""

echo "creating and migrating default database in config/database.yml. please wait..."
rake db:create db:migrate --trace
echo ""

define GOODBYE_MSG <<'EOT'
#####################################################################

It worked! :)

Now, you should have a look at

  - config/database.yml      and
  - config/application.yml

and change them to your liking. Then you should be able to
start Diaspora* in development mode with:

    `rails s`

EOT
echo "$GOODBYE_MSG"
echo "For further information read the wiki at $D_WIKI_URL"
echo "or join us on IRC $D_IRC_URL"
echo ""


exit 0

