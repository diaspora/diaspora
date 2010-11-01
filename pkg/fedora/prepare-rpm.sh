#!/bin/bash

# Create RPM spec files matching diaspora tarballs
#
# Usage: See  function usage() at bottom.
#
GIT_REPO='http://github.com/diaspora/diaspora.git'
VERSION='0.0'
RELEASE='1'

. ../source/funcs.sh


function fix_alphatag()
#  Patch version on top comment first id line:
#  Usage: fix_alphatag <file> <version> <commit_id> <release>
#  Patches:\
#       *   Fri Sep 24 2010 name surname <email@com> 1.20100925_faf23207
{
    local dist=$(rpm --eval %dist)
    awk -v dist="$dist" -v version="$2" -v commit="$3" -v release="$4" \
      ' BEGIN    { done = 0 }
        /^[*]/   { if (done)
                       print
                   else
                   {
                       s = sprintf( "-%s.%s%s\n", release, commit, dist)
                       gsub( "-[0-9][.][^ ]*$", s)
                       done = 1
                       # add new gsub for version...
                       print
                   }
                   next
                 }
                 { print }'  < $1 > $1.tmp && mv -f $1.tmp $1
}


function fix_bundle_deps
# usage: fix_bundle_deps <specfile> <version> <commit>
# Patches: Requires:   diaspora-bundle = 0.0-20101021-aefsf323148
{
        awk -v vers="$2-$3" \
                ' /Requires:/ { if ($2 == "diaspora-bundle")
                                    printf( "%s %s = %s\n", $1,$2,vers)
                                else
                                    print
                                next
                              }
                              { print}' \
             < $1 > $1.tmp && mv -f  $1.tmp $1
}


function patch()
# Patch  spec-files with current version-release
# Usage: patch <version> <commit> <release>
{
        sed -e "/^%define/s|HEAD|$2|"                  \
            -e '/^Version:/s|.*|Version:        '$1'|' \
                <diaspora.spec >dist/diaspora.spec
        fix_alphatag dist/diaspora.spec $1 $2 $3
        local bundle_id=$(git_id dist/diaspora/Gemfile)
        local dist_tag=$(rpm --eval %dist)
        fix_bundle_deps  dist/diaspora.spec $1 "$RELEASE.${bundle_id}$dist_tag"
        sed -e "/^%define/s|HEAD|$bundle_id|"          \
            -e '/^Version:/s|.*|Version:        '$1'|' \
                < diaspora-bundle.spec > dist/diaspora-bundle.spec

        cp dist/diaspora.spec dist/diaspora/diaspora.spec
}


function prepare_rpm()
# Usage: prepare_rpm < commit>
{
    local dest=$(rpm --eval %_sourcedir)
    test -z "$dest" && {
        echo "Can't find RPM source directory, giving up."
        exit 2
    }

    local commit=$( checkout $1)
    echo "Release:             $RELEASE.$commit"
    echo "Rpm source dir:      $dest"

    patch $VERSION $commit $RELEASE

    local src="dist/diaspora-$VERSION-$commit.tar.gz"
    test -e $src ||
        cat <<- EOF
	Warning: $src does not exist
	(last version not built?)
	EOF
    ln -sf $PWD/$src $dest

    local bundle_commit=$( git_id dist/diaspora/Gemfile)
    local bundle="dist/diaspora-bundle-$VERSION-$bundle_commit.tar.gz"
    test -e $bundle ||
        cat <<- EOF
	Warning: $bundle does not exist
	(last version not built?)
	EOF
    ln -sf $PWD/$bundle $dest

    local file
    for file in $( grep -v '^#' SOURCES); do
        if [ -e "$file" ]; then
            ln -sf $PWD/$file $dest/$file
        else
            echo "Warning: $file (listed in SOURCES) does not exist"
        fi
    done

    ( cd $dest;  find . -type l -not -readable -exec rm {} \;)
    echo "Source specfile:     dist/diaspora.spec"
    echo "Bundle specfile:     dist/diaspora-bundle.spec"
}


function usage()
{
        cat <<- EOF

	Usage: prepare-rpm [options]

	Options:

	-h             Print this message.
	-r  release    For prepare, mark with release nr, defaults to 1.
	-u  uri        Git repository URI, defaults to
	               $GIT_REPO.

	Symlink bundle and source tarballs to rpm source dir, create
        patched  rpm spec files.

	All results are stored in dist/

	EOF
}


commit='HEAD'
BUNDLE_FIX='no'
while getopts ":r:u:h" opt
do
    case $opt in
        r)   RELEASE="$OPTARG:"
             ;;
        h)   usage
             exit 0
             ;;
        u)   GIT_REPO="$OPTARG"
             ;;
        *)   usage
             exit 2
             ;;
    esac
done
shift $(($OPTIND - 1))

typeset -r GIT_REPO RELEASE BUNDLE_FIX
export LANG=C

test $# -gt 0  && {
    usage;
    exit 2;
}
prepare_rpm
