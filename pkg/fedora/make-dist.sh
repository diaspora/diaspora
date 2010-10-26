#!/bin/bash

# Create a diaspora distribution
#
# Usage: See  function usage() at bottom.
#
GIT_REPO='http://github.com/diaspora/diaspora.git'
VERSION='0.0'
RELEASE='1'


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

    (
        cd $dir
        git log -1 --abbrev-commit --date=iso $file |
            awk  -v nl="$nl" \
               ' BEGIN         { commit = ""; d[1] = "" }
                /^commit/      { if ( commit ==  "") commit = $2 }
                /^Date:/       { if (d[1] == "") {
                                     split( $2, d, "-")
                                     split( $3, t, ":")
                                 }
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


function checkout()
# Checkout last version of diaspora unless it's already there.
# Usage: checkout [commit id, defaults to HEAD]
# Returns: commit for current branch's HEAD.
{
    mkdir dist  &>/dev/null || :
    (
        local last_repo=''
        cd dist

        test -e '.last-repo' &&
            last_repo=$( cat '.last-repo')
        test  "$last_repo" != $GIT_REPO &&
            rm -rf diaspora
        test -d diaspora || {
            git clone --quiet $GIT_REPO;
            (
                cd diaspora;
                git remote add upstream \
                    git://github.com/diaspora/diaspora.git
                for p in ../../*.patch; do
                    git apply --whitespace=fix  $p  > /dev/null
                done &> /dev/null || :
            )
        }
        echo -n "$GIT_REPO" > '.last-repo'

        cd diaspora;
        git fetch --quiet upstream
        git merge --quiet upstream/master
        [ -n "$1" ] && git reset --hard  --quiet  $1
        git_id  -n
    )
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

function fix_gemfile
{
    sed -i  's|git://.*/|vendor/git/|g' $1

}

function build_git_gems()
# Usage: build_git_gems <Gemfile> <tmpdir> <gemdir>
# Horrible hack, in wait for bundler handling git gems OK.
{
    mkdir gem-tmp || :
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
                    suffix = "; cd " name
                    for (i = 3; i <= NF; i += 1) {
                        key = $i
                        i += 1
                        if (key == ":git")
                            url = $i
                        else if ( key == ":ref")
                            suffix = suffix "; git reset --hard " $i
                        else if ( key == ":branch")
                            suffix = suffix "; git checkout " $i
                    }
                    suffix = suffix "; cd .."
                    cmd =  sprintf( "git clone --quiet %s %s %s\n",
                                     url, name, suffix)
                    print "Running: ", cmd
                    system( cmd)
                    cmd = sprintf( "git clone --bare --quiet %s\n", url)
                    print "Running: ", cmd
                    system( cmd)
                }'
    sed -i 's/Date.today/"2010-10-24"/' carrierwave/carrierwave.gemspec
    for dir in *; do
        if  [ -e  $dir/*.gemspec ] ; then
            cd $dir
                gem build *.gemspec
                cp *.gem ../../$2
            cd ..
        else
            cp -ar $dir ../$2
        fi
    done
    cd ..
    # rm -rf gem-tmp
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
                if [ "$BUNDLE_FIX" = 'yes' ]; then
                    rm -f Gemfile.lock
                    rm -rf .bundle
                    bundle update
                fi

                [ -d 'vendor/git' ] || mkdir  vendor/git
                build_git_gems  Gemfile vendor/git
                sed -i  's|git://.*/|vendor/git/|g' Gemfile
                rm Gemfile.lock
                rm -rf .bundle
                # see: http://bugs.joindiaspora.com/issues/440
                bundle install --path=vendor/bundle  ||
                     bundle install --path=vendor/bundle
                bundle package

                mkdir  -p "../$bundle_name/docs"
                mkdir -p "../$bundle_name/vendor"
                cp -ar AUTHORS Gemfile Gemfile.lock GNU-AGPL-3.0 COPYRIGHT \
                    ../$bundle_name

                make_docs "vendor/bundle/ruby/1.8/gems/"  "../$bundle_name/docs"
                mv vendor/cache ../$bundle_name/vendor
                mv vendor/git  ../$bundle_name/vendor
                rm -rf vendor/gems/*
            cd ..
            tar czf $bundle_name.tar.gz $bundle_name
            mv $bundle_name/vendor/cache diaspora/vendor/cache
        cd ..
    }
    echo
    echo "Bundle: dist/$bundle_name.tar.gz"
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

	Usage: make-dist [options]  <dist|bundle|prepare>

	Options:

	-h             Print this message.
	-c  commit     Use a given commit, defaults to last checked in.
	-r  release    For prepare, mark with release nr, defaults to 1.
	-u  uri        Git repository URI, defaults to
	               $GIT_REPO.
	-f             For bundle, fix dependencies by running 'bundle update'
	               before 'bundle install'

	source         Build a diaspora application tarball.
	bundle         Build a bundler(1) bundle for diaspora.
	prepare        Symlink bundle and source tarballs to rpm source dir,
	               create patched  rpm spec files.

	All results are stored in dist/

	EOF
}


commit='HEAD'
BUNDLE_FIX='no'
while getopts ":r:c:u:fh" opt
do
    case $opt in
        u)   GIT_REPO="$OPTARG"
             ;;
        c)   commit="${OPTARG:0:7}"
             ;;
        r)   RELEASE="$OPTARG:"
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

typeset -r GIT_REPO RELEASE BUNDLE_FIX
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
   'prepare')  prepare_rpm  $commit $release
               ;;
           *)  usage
               exit 1
               ;;
esac



