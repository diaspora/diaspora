#!/bin/bash

#Usage: See  function usage() at bottom.
#
#
# Create a diaspora distribution
#
# Builds a diaspora distribution containing the application and bundled
# libraries. Normally checks out latest version of the master branch.
#
GIT_REPO='http://github.com/diaspora/diaspora.git'
RELEASE='HEAD'
VERSION='0.0'

function git_id
#
# Echo package-friendly source id.
#
# Usage: git_id [-n] [file or directory]
#
{
    nl="\n"
    file_or_dir="$PWD"
    test "$1" = '-n' && { nl=""; shift; }
    test -n "$1" && file_or_dir="$1"
    if [ -d $file_or_dir ]; then
        file=""
        dir=$file_or_dir
    else
        file=$(basename $file_or_dir) 
        dir=$(dirname $file_or_dir)
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
#  Uses %define git_release to get release.
#* Fri Sep 24 2010 name surname  <email@com>     1.20100925_faf234320
{
    dist=$(rpm --eval %dist)
    awk  -v dist="$dist" -v version="$2"  \
        ' BEGIN         { done = 0 }
          /%define/     { if ($2 = "git_release") release = $3 }
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
    < $1 > $1.tmp && cp $1.tmp $1 && rm $1.tmp
}

function fix_bundle_deps
# usage: fix_bundle_deps <specfile> <version> release
# Patches Requires:   diaspora-bundle = 0.0-20101021-aefsf323148
{
	awk -v vers="$2-$3" \
		' /Requires:/ { if ($2 == "diaspora-bundle")
				    printf( "%s	%s = %s\n", $1,$2,vers)
				else
				    print				    
				next
			       }
			       { print}' \
             < $1 > $1.tmp && cp $1.tmp $1 && rm $1.tmp			    
}

function patch()
# Patch git_release, Requires: diaspora-bundle and top comment version.
# Usage: patch VERSION RELEASE
{
	sed -e "/^%define/s|HEAD|$2|"                  \
            -e '/^Version:/s|.*|Version:        '$1'|' \
                <diaspora.spec >dist/diaspora.spec                              
	fix_alphatag dist/diaspora.spec $1
	#mkdir dist/diaspora/tmp || :
	bundle_id=$(git_id dist/diaspora/Gemfile)
	fix_bundle_deps  dist/diaspora.spec $1 "1.$bundle_id.fc13"
	sed -e "/^%define/s|HEAD|$bundle_deps|"        \
            -e '/^Version:/s|.*|Version:        '$1'|' \
                < diaspora-bundle.spec > dist/diaspora-bundle.spec
	
	cp dist/diaspora.spec dist/diaspora/diaspora.spec
}

function checkout()
# Checkout last version of diaspora unless it's already there.
# Usage: checkout [commit id, defaults to HEAD]
# Returns: commit for current branch's HEAD.
{   
    mkdir dist  >/dev/null 2>&1 || :
    (
        cd dist 
        test -d diaspora || {
             git clone --quiet $GIT_REPO; 
             (
                 cd diaspora;
                 git remote add upstream \
                     git://github.com/diaspora/diaspora.git
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
{
    commit=$(checkout ${1:-'HEAD'})
    echo "Creating source tarball for $commit"
    patch $VERSION $commit 
	
    RELEASE_DIR="diaspora-$VERSION-$commit"
    rm -rf dist/${RELEASE_DIR} 
    mkdir dist/${RELEASE_DIR}
    cp diaspora-ws diaspora-setup diaspora.logconf dist/${RELEASE_DIR}
    cd dist
    mkdir ${RELEASE_DIR}/master
    cp -ar diaspora/*  diaspora/.git* ${RELEASE_DIR}/master	
    cp -r ../.bundle ${RELEASE_DIR}/master
    mv  ${RELEASE_DIR}/master/diaspora.spec  ${RELEASE_DIR}
    tar czf ${RELEASE_DIR}.tar.gz  ${RELEASE_DIR} && rm -rf ${RELEASE_DIR}
    cd ..
    bundle_id=$(git_id dist/diaspora/Gemfile)
    echo "Source:           dist/${RELEASE_DIR}.tar.gz"
    echo "Required bundle:  $bundle_id"
    echo "Source specfile:  dist/diaspora.spec"
    echo "Bundle specfile:  dist/diaspora-bundle.spec"
}

function make_bundle()
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
                test -e ../../Gemfile.lock.patch &&
		    git apply ../../Gemfile.lock.patch > /dev/null 2>&1
                rm -rf devise.tmp
                git clone http://github.com/BadMinus/devise.git devise.tmp
                ( cd devise.tmp; gem build devise.gemspec)
                gem install --install-dir "../$bundle_name/bundle/ruby/1.8" \
                            --no-rdoc --no-ri                      \
                            --ignore-dependencies                  \
                            devise.tmp/devise-1.1.rc1.gem  &&
                   rm -rf devise.tmp

	        bundle install --deployment                      \
                               --path="../$bundle_name/bundle"   \
                               --without=test rdoc

	        cp AUTHORS Gemfile GNU-AGPL-3.0 COPYRIGHT "../$bundle_name"
            popd
            tar czf $bundle_name.tar.gz $bundle_name
    }
    echo 
    echo "Bundle: dist/$bundle_name.tar.gz"
}

function make_links()
# Usage: make_links [source commit]
{
    dest=$(rpm --eval %_sourcedir)
    test -z "$dest" && {
        echo "Can't find RPM source directory, giving up."
        exit 2
    }
    echo "Linking sources to $dest"

    src_commit="$1"
    test -z "$src_commit" && {
         src_commit=$(checkout)
    }
    src="dist/diaspora-$VERSION-$src_commit.tar.gz"
    ln -sf $PWD/$src $dest

    bundle_commit=$(git_id dist/diaspora/Gemfile)
    bundle="dist/diaspora-bundle-$VERSION-$bundle_commit.tar.gz"
    ln -sf $PWD/$bundle $dest

    for file in $( egrep -v '^#' SOURCES); do
        ln -sf $PWD/$file $dest/$file
    done

    cd $dest
    find . -type l -not -readable -exec rm {} \;
}

function usage()
{
    	cat <<- EOF

		Usage: make_dist [-c commit] <dist|bundle|links>

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

     "fix_gemfile")
                fix_gemfile
                ;;
                
            *)  usage
                exit 1
                ;;
 esac
 
         

