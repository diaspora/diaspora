#
# Common stuff for pkg scripts
#

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

function checkout()
# Checkout last version of diaspora unless it's already there.
# Uses global GIT_REPO to determine repo url
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
                git checkout Gemfile Gemfile.lock
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

function init_appconfig
# Edit pod_url in hostname
# Silently uses argumetn if present, else run dialog.
# Usage: init_appconfig <app_config.yml> [hostname]
{
    config=$1
    arg_hostanme="$2"
    hostname=$( awk '/pod_url:/ { print $2; exit }' <$config )

    if [ -n "$arg_hostname" ]; then
        sed -i "/pod_url:/s|$hostname|$arg_hostname|g" $config && \
            echo "config/app_config.yml updated."
        return 0
    else
        while : ; do
            echo "Current hostname is \"$hostname\""
            echo -n "Enter new hostname [$hostname] :"
            read new_hostname garbage
            echo -n "Use \"$new_hostname\" as pod_url (Yes/No) [Yes]? :"
            read yesno garbage
            [ "${yesno:0:1}" = 'y' -o "${yesno:0:1}" = 'Y' -o -z "$yesno" ] && {
                sed -i "/pod_url:/s|$hostname|$new_hostname|g" $config &&
                    echo "config/app_config.yml updated."
                break
            }
        done
    fi
}

