#!/bin/bash

# Create diaspora distribution tarballs.
#
# Usage: See  function usage() at bottom.
#
GIT_REPO='http://github.com/diaspora/diaspora.git'
VERSION='0.0'

. ./funcs.sh

function build_git_gems()
# Usage: build_git_gems <Gemfile> <tmpdir> <gemdir>
# Horrible hack, in wait for bundler handling git gems OK.
{
    [ -d 'gem-tmp' ] || mkdir gem-tmp
    cd gem-tmp
    rm -rf *

    grep 'git:'  ../$1 |  sed 's/,/ /g' | awk '
       /^.*git:\/\/.*$/  {
                    gsub( "=>", " ")
                    if ( $1 != "gem") {
                          print "Strange git: line (ignored) :" $0
                          next
                    }
                    name = $2
                    url=""
                    for (i = 3; i <= NF; i += 1) {
                        key = $i
                        i += 1
                        if (key == ":git")
                            url = $i
                    }
                    cmd = sprintf( "git clone --bare --quiet %s\n", url)
                    print "Running: ", cmd
                    system( cmd)
                }'
    mv devise-mongo_mapper.git  devise-mongo_mapper
    for dir in *; do
        if  [ ! -e  $dir/*.gemspec ]; then
            cp -ar $dir ../$2
        fi
    done
    cd ..
    # rm -rf gem-tmp
}

function make_src
# Create a distribution tarball
# Usage:  make src  <commit>
{
    echo "Using repo:          $GIT_REPO"

    commit=$(checkout ${1:-'HEAD'})
    echo "Commit id:           $commit"

    RELEASE_DIR="diaspora-$VERSION-$commit"
    rm -rf dist/${RELEASE_DIR}
    mkdir dist/${RELEASE_DIR}
    cd dist
        mkdir ${RELEASE_DIR}/master
        cp -ar diaspora/*  diaspora/.git* ${RELEASE_DIR}/master
        (
             cd  ${RELEASE_DIR}/master
             rm -rf vendor/bundle/* vendor/git/* vendor/cache/* gem-tmp
             git show --name-only > config/gitversion
             tar czf public/source.tar.gz  \
                 --exclude='source.tar.gz' -X .gitignore *
             find $PWD  -name .git\* | xargs rm -rf
             rm -rf .bundle
             /usr/bin/patch -p1 -s <../../../add-bundle.diff
        )
        tar czf ${RELEASE_DIR}.tar.gz  ${RELEASE_DIR} && \
            rm -rf ${RELEASE_DIR}
    cd ..
    echo "Source:              dist/${RELEASE_DIR}.tar.gz"
    echo "Required bundle:     $(git_id dist/diaspora/Gemfile)"
}

function make_docs()
{
    local gems=$1
    local dest=$2

    for gem in $(ls $gems); do
        local name=$(basename $gem)
        [ -r "$gems/$gem/README*" ] && {
             local readme=$(basename $gems/$gem/README*)
             cp  -a $gems/$gem/$readme $dest/$readme.$name
        }
        [ -r "$gems/$gem/COPYRIGHT" ] && \
             cp -a $gems/$gem/COPYRIGHT $dest/COPYRIGHT.$name
        [ -r "$gems/$gem/LICENSE" ] && \
             cp -a $gems/$gem/LICENSE $dest/LICENSE.$name
        [ -r "$gems/$gem/License" ] && \
             cp -a $gems/$gem/License $dest/License.$name
        [ -r "$gems/$gem/MIT-LICENSE" ] && \
             cp -a $gems/$gem/MIT-LICENSE $dest/MIT-LICENSE.$name
        [ -r "$gems/$gem/COPYING" ] && \
             cp -a $gems/$gem/COPYING $dest/COPYING.$name
    done
}



function make_bundle()
# Create the bundle tarball
# Usage:  make_bundle [ commit, defaults to HEAD]
#
{
    checkout ${1:-'HEAD'} >/dev/null
    local bundle_id=$( git_id dist/diaspora/Gemfile)
    local bundle_name="diaspora-bundle-$VERSION-$bundle_id"
    test -e  "dist/$bundle_name.tar.gz" || {
        echo "Creating bundle $bundle_name"
        cd dist
            rm -rf $bundle_name
            cd diaspora
                rm Gemfile.lock
                rm -rf .bundle
                if [ "$BUNDLE_FIX" = 'yes' ]; then
                    bundle update
                fi

                [ -d 'git-repos' ] || mkdir  git-repos
                rm -rf git-repos/*
                git checkout Gemfile
                build_git_gems  Gemfile git-repos
                sed -i  's|git://.*/|git-repos/|g' Gemfile
                # see: http://bugs.joindiaspora.com/issues/440
                bundle install --path=vendor/bundle  || {
                    bundle install --path=vendor/bundle || {
                        echo "bundle install failed, giving up" >&2
                        exit 3
                    }
                }
                bundle package

                mkdir  -p "../$bundle_name/docs"
                mkdir -p "../$bundle_name/vendor"
                cp -ar AUTHORS Gemfile Gemfile.lock GNU-AGPL-3.0 COPYRIGHT \
                    ../$bundle_name

                make_docs "vendor/bundle/ruby/1.8/gems/"  "../$bundle_name/docs"
                mv vendor/cache ../$bundle_name/vendor
                mv vendor/gems ../$bundle_name/vendor
                mv git-repos ../$bundle_name
                git checkout Gemfile
            cd ..
            tar czf $bundle_name.tar.gz $bundle_name
            mv $bundle_name/vendor/cache diaspora/vendor/cache
        cd ..
    }
    echo
    echo "Bundle: dist/$bundle_name.tar.gz"
}

function usage()
{
        cat <<- EOF

	Usage: make-dist [options]  <dist|bundle>

	Options:

	-h             Print this message.
	-c  commit     Use a given commit, defaults to last checked in.
	-u  uri        Git repository URI, defaults to
	               $GIT_REPO.
	-f             For bundle, fix dependencies by running 'bundle update'
	               before 'bundle install'

	source         Build a diaspora application tarball.
	bundle         Build a bundler(1) bundle for diaspora.

	All results are stored in dist/

	EOF
}


commit='HEAD'
BUNDLE_FIX='no'
while getopts ":c:u:fh" opt
do
    case $opt in
        u)   GIT_REPO="$OPTARG"
             ;;
        c)   commit="${OPTARG:0:7}"
             ;;
        f)   BUNDLE_FIX='yes'
             ;;
        h)   usage
             exit 0
             ;;
        *)   usage
             exit 2
             ;;
    esac
done
shift $(($OPTIND - 1))

typeset -r GIT_REPO  BUNDLE_FIX
export LANG=C

test $# -gt 1 -o $# -eq 0 && {
    usage;
    exit 2;
}

case $1 in

    "bundle")  make_bundle $commit $BUNDLE_FIX
               ;;
    'source')  make_src $commit
               ;;
           *)  usage
               exit 1
               ;;
esac



