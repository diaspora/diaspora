#!/bin/bash

# Create a diaspora distribution
#
# Usage: See  function usage() at bottom.
#
GIT_REPO='http://github.com/diaspora/diaspora.git'
VERSION='0.0'

function git_id
#
# Echo package-friendly source id.
#
# Usage: git_id [-n] [file or directory]
#
{
    local nl="\n"
    local file_or_dir="$PWD"
    test "$1" = '-n' && { nl=""; shift; }
    test -n "$1" && file_or_dir="$1"
    if [ -d $file_or_dir ]; then
        local file=""
        local dir=$file_or_dir
    else
        local file=$(basename $file_or_dir)
        local dir=$(dirname $file_or_dir)
    fi

    export LANG=C
    (
        cd $dir
        git log -1 --abbrev-commit --date=iso $file |
        awk  -v nl="$nl" \
          ' BEGIN         { commit = "" }
           /^commit/      { if ( commit ==  "") commit = $2 }
           /^Date:/       { split( $2, d, "-")
                            split( $3, t, ":")
                          }
           END            { printf( "%s%s%s%s%s_%s%s",
                                substr( d[1],3), d[2], d[3],
                                t[1], t[2],
                                commit, nl)
                          }'
    )
}


function fix_alphatag()
#  Patch version on top comment first id line:
#  Usage: fix_alphatag <file> <version> <commit_id>
#  Patches:\
#       *   Fri Sep 24 2010 name surname <email@com> 1.20100925_faf23207
{
    local dist=$(rpm --eval %dist)
    awk  -v dist="$dist" -v version="$2" -v release="$3"  \
        ' BEGIN         { done = 0 }
          /^[*]/        { if (done)
                             print
                          else
                          {
                             gsub( "1[.].*", "")
                             printf( "%s%s-1.%s%s\n",
                                     $0, version, release,dist)
                             done = 1
                          }
                          next
                        }
                        { print }' \
    < $1 > $1.tmp && mv -f $1.tmp $1
}

function fix_bundle_deps
# usage: fix_bundle_deps <specfile> <version> <release>
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
# Usage: patch VERSION RELEASE
{
        sed -e "/^%define/s|HEAD|$2|"                  \
            -e '/^Version:/s|.*|Version:        '$1'|' \
                <diaspora.spec >dist/diaspora.spec
        fix_alphatag dist/diaspora.spec $1 $2
        local bundle_id=$(git_id dist/diaspora/Gemfile)
        local dist_tag=$(rpm --eval %dist)
        fix_bundle_deps  dist/diaspora.spec $1 "1.${bundle_id}$dist_tag"
        sed -e "/^%define/s|HEAD|$bundle_id|"          \
            -e '/^Version:/s|.*|Version:        '$1'|' \
                < diaspora-bundle.spec > dist/diaspora-bundle.spec

        cp dist/diaspora.spec dist/diaspora/diaspora.spec
}

function checkout()
# Checkout last version of diaspora unless it's already there.
# Usage: checkout [commit id, defaults to HEAD]
# Returns: commit for current branch's HEAD.
{
    mkdir dist  &>/dev/null || :
    (
        cd dist
        test -d diaspora || {
             git clone --quiet $GIT_REPO;
             (
                 cd diaspora;
                 git remote add upstream \
                     git://github.com/diaspora/diaspora.git
                 for p in ../../*.patch; do
                     git apply --whitespace=fix  $p  > /dev/null
                 done &>/dev/null  || :
             )
        }
        cd diaspora;
        git fetch --quiet upstream
        git merge --quiet upstream/master
        git checkout --quiet  ${1:-'HEAD'}
        git_id  -n
    )
}


function make_dist
# Create a distribution tarball
# Usage:  make dist [ commit, defaults to HEAD]
{
    commit=$(checkout ${1:-'HEAD'})
    echo "Creating source tarball for $commit"
    patch $VERSION $commit

    RELEASE_DIR="diaspora-$VERSION-$commit"
    rm -rf dist/${RELEASE_DIR}
    mkdir dist/${RELEASE_DIR}
    cd dist
        mkdir ${RELEASE_DIR}/master
        cp -ar diaspora/*  diaspora/.git* ${RELEASE_DIR}/master
        mv  ${RELEASE_DIR}/master/diaspora.spec  ${RELEASE_DIR}
        (
             cd  ${RELEASE_DIR}/master
             git show --name-only > config/gitversion
             tar cf public/source.tar  \
                 --exclude='source.tar' -X .gitignore *
             find $PWD  -name .git\* | xargs rm -rf
             rm -rf .bundle
             /usr/bin/patch -p1 <../../../add-bundle.diff
        )
        tar czf ${RELEASE_DIR}.tar.gz  ${RELEASE_DIR} && \
            rm -rf ${RELEASE_DIR}
    cd ..
    echo "Source:           dist/${RELEASE_DIR}.tar.gz"
    echo "Required bundle:  $(git_id dist/diaspora/Gemfile)"
    echo "Source specfile:  dist/diaspora.spec"
    echo "Bundle specfile:  dist/diaspora-bundle.spec"
}

function make_bundle()
# Create the bundle tarball
# Usage:  make_bundle [ commit, defaults to HEAD]
#
{
    checkout ${1:-'HEAD'} >/dev/null
    bundle_id=$(git_id dist/diaspora/Gemfile)
    bundle_name="diaspora-bundle-$VERSION-$bundle_id"
    test -e  "dist/$bundle_name.tar.gz" || {
        echo "Creating bundle $bundle_name"
        cd dist
            rm -rf $bundle_name
            mkdir -p $bundle_name/bundle
            pushd diaspora > /dev/null
                bundle install --deployment                      \
                               --path="../$bundle_name/bundle"   \
                               --without=test rdoc

                cp -ar AUTHORS Gemfile GNU-AGPL-3.0 COPYRIGHT \
                       "../$bundle_name"
            popd > /dev/null
            tar czf $bundle_name.tar.gz $bundle_name
        cd ..
    }
    echo
    echo "Bundle: dist/$bundle_name.tar.gz"
}

function make_links()
# Usage: make_links [source commit]
{
    local dest=$(rpm --eval %_sourcedir)
    test -z "$dest" && {
        echo "Can't find RPM source directory, giving up."
        exit 2
    }

    local src_commit="${1:-$( checkout)}"
    echo "Linking sources for $src_commit to $dest"

    src="dist/diaspora-$VERSION-$src_commit.tar.gz"
    test -e $src ||
        cat <<- EOF
	Warning: $src does not exist
	(last version not built?)
	EOF
    ln -sf $PWD/$src $dest

    local bundle_commit=$(git_id dist/diaspora/Gemfile)
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
}

function usage()
{
        cat <<- EOF

	Usage: make-dist [-c commit] <dist|bundle|links>

	-c             Use a given commit, defaults to last checked in.
	dist           Build a diaspora application tarball.
	bundle         Build a bundler(1) bundle for diaspora.
	links          Symlink bundle and source tarballs to rpm source dir.

	All results are stored in dist/
	EOF
}


test "$1" = "-h"  -o $# = 0 && {
    usage;
    exit 0
}

test "$1" = "-c" && {
    test -z "$2" && {
        usage;
        exit 1
    }
    commit="$2"
    shift; shift
}


case $1 in

    "bundle")  make_bundle $commit
               ;;

    'source')  make_dist $commit
               ;;

    'links')   make_links $commit
               ;;

           *)  usage
               exit 1
               ;;
esac



