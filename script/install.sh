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

BINARIES="git ruby gem bundle"       # required programs

D_GIT_CLONE_PATH="/srv/diaspora"     # path for diaspora

D_REMOTE_REPO_URL="git://github.com/diaspora/diaspora.git"

D_WIKI_URL="https://github.com/diaspora/diaspora/wiki"

D_IRC_URL="irc://freenode.net/diaspora"


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
sane_environment_check() {
  for exe in $BINARIES; do
    echo -n "checking for $exe... " 
    which "$exe"
    if [ $? -gt 0 ]; then
      error "you are missing $exe";
    fi
  done
  echo ""
}

# find or set up a working git environment
git_stuff_check() {
  echo "Where would you like to put the git clone?\n(or, where is your git clone)? "
  read -e -p "-> " -i "$D_GIT_CLONE_PATH" D_GIT_CLONE_PATH
  echo ""

  test -d "$D_GIT_CLONE_PATH" \
    && cd "$D_GIT_CLONE_PATH" \
    && git status "$D_GIT_CLONE_PATH"  # folder exists? go there. is a good git clone?
  if [ $? -gt 0 ]; then
    mkdir "$D_GIT_CLONE_PATH" # only if it doesn't exist
    # not a git repo, create it?
    echo "the folder you specified does not contain a git repo, create one?"
    select choice in "Yes" "No"; do
      case $choice in
        Yes ) git clone "$D_REMOTE_REPO_URL" "$D_GIT_CLONE_PATH"; break ;;
        No ) error "please make sure you have a git clone somewhere" ;;
      esac
    done
  else
    git checkout master
    git pull
  fi
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


echo "initializing Diaspora*"
echo "copying database.yml.example to database.yml"
cp config/database.yml.example config/database.yml
echo ""

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

