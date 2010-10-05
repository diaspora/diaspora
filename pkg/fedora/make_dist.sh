#!/bin/bash

#Usage: make_dist [-b] [-d] [s] [-c <commit>] 
#
# -b create a bundler bundle for diaspora
# -d create a diaspora source tarball
# -s synchronize Gemfile.lock VERY INTRUSIVE to RUBY ENVIRONMENT
# -c Use a given commit instead of last available

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
         ' /commit/       { commit = $2 }
           /Date/         { split( $2, d, "-")
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
# Returns: commit for current branch's HEAD.
{   
    mkdir dist || :
    (
        cd dist 
        test -d diaspora && {
            ( cd diaspora; git_id -n)
            return
        }
        git clone --quiet $GIT_REPO;      \
        cd diaspora; 
        git checkout --quiet -b dist $GIT_VERSION; 
        git_id  -n 
    )
}


function make_dist
# Create a distribution tarball
{
    commit=$(checkout)
    patch $VERSION $commit 
	
    RELEASE_DIR="diaspora-$VERSION-$commit"
    rm -rf dist/${RELEASE_DIR} 
    mkdir dist/${RELEASE_DIR}
    cp diaspora-ws    dist/${RELEASE_DIR}
    cp diaspora.logconf  dist/${RELEASE_DIR}
    cd dist
    mkdir ${RELEASE_DIR}/master
    cp -ar diaspora/*  ${RELEASE_DIR}/master	
    mv  ${RELEASE_DIR}/master/diaspora.spec  ${RELEASE_DIR}
    tar czf ${RELEASE_DIR}.tar.gz  ${RELEASE_DIR} && rm -rf ${RELEASE_DIR}
}

#set -x
#mkdir dist || :
#pushd dist
#    test -d diaspora || {
##         git clone  $GIT_REPO;      
#         pushd diaspora
#             git checkout -b dist $RELEASE;
#	     git add upstream $GIT_REPO#
#	 popd
#    }
#    pushd diaspora
#        git fetch upstream
#        git merge upstream/master
#    popd
#popd

function make_bundle()
{
    bundle_id=$(git_id dist/diaspora/Gemfile)
    bundle_name="diaspora-bundle-$VERSION-$bundle_id"
    test -e  "$bundle_name" || {
       	cd dist
	    rm -rf $bundle_name 
	    mkdir -p $bundle_name/bundle
	    pushd diaspora
	        bundle  install --deployment --path="../$bundle_name/bundle"  --without=test rdoc
	       cp AUTHORS Gemfile GNU-AGPL-3.0 COPYRIGHT "../$bundle_name"
            popd
            tar czf $bundle_name.tar.gz $bundle_name
    }
}

function make_links()
# Usage: make_links [source commit]
{
    dest=$(rpm --eval %_sourcedir)
    test -z "$dest" && {
        echo "Can't find RPM source directory, giving up."
        exit 2
    }

    src_commit="$1"
    test -z "$src_commit" && {
         src_commit=$(checkout)
    }
    src="dist/diaspora-$VERSION-$src_commit.tar.gz"
    ln -sf $PWD/$src $dest

    bundle_commit=$(git_id dist/diaspora/Gemfile)
    bundle="dist/diaspora-bundle-$VERSION-$bundle_commit.tar.gz"
    ln -sf $PWD/$bundle $dest
    cd $dest
    find . -type l -not -readable -exec rm {} \;
}

    
  



function usage()
{
    	cat <<- EOF
		Usage: make_dist [-c commit] <dist|bundle|fix_gemlock>
		-c             Use a given commit, defaults to last checked in.
		dist           Build a diaspora application tarball.
		bundle         Build a bundler(1) bundle for diaspora.
		fix_gemlock    Try to fix out-of order gemlock, VERY INTRUSIVE.
		
		All results are stored in dist/
	EOF
}		
test "$1" = "-h"  -o $# = 0 && {
    usage;
    exit 0
}

test "$1" = "-c" && {
    test-z "$2" && {
        usage;
        exit 1
    }
    commit="$2"
    shift; shift
}
    
    
 case $1 in
 
     "bundle")  make_bundle $commit
                ;;
     'source')    make_dist $commit
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
 
         

