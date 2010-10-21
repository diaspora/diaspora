%define         git_release     HEAD

# Turn off java repack, this is in /usr/lib[64] anyway
%define         __jar_repack    %{nil}

# Turn off the brp-python-bytecompile script, *pyc/pyo causes problems
%global __os_install_post %(echo '%{__os_install_post}' |
       sed -e 's!/usr/lib[^[:space:]]*/brp-python-bytecompile[[:space:]].*$!!g')

Summary:        Rubygem bundle for diaspora
Name:           diaspora-bundle
Version:        0.0
Release:        1.%{git_release}%{?dist}
License:        Ruby
Group:          Applications/Communications
URL:            http://www.joindiaspora.com/
Vendor:         joindiaspora.com
Source:         %{name}-%{version}-%{git_release}.tar.gz
Prefix:         %{_prefix}
BuildRoot:      %{_tmpdir}/not-used-since-F13/

Requires(pre):  shadow-utils
Requires:       ruby(abi) = 1.8

%description
The ruby apps bundled with diaspora, as provided by
bundle install --package and patched for Fedora use.

%package devel
Summary:   Development files (i. e., sources) for diaspora-bundle
Group:     Development/Libraries
Requires:  %{name} = %{version}

%description devel
Source file usede to compile native libraries in diaspora-bundle.

%prep
%setup -q -n %{name}-%{version}-%{git_release}

%build
mkdir -p vendor/cache
mv *.gem vendor/cache
for gem in vendor/cache/*.gem; do
    gem install --local                      \
                --install-dir vendor/bundle  \
                --no-rdoc                    \
                --no-ri                      \
                --no-test                    \
                --no-wrappers                \
                --ignore-dependencies        \
                $gem
done

pushd vendor/bundle/gems
    # In repo (2.2.4)
    test -d gherkin-*/ext && {
    pushd gherkin-*/ext
    # Recompile all shared libraries using -O2 flag
    for lexer_dir in */ ; do
        pushd $lexer_dir
            sed -i 's/ -O0 / -O2 /' extconf.rb
            # Remove #line lines from C sources
            sed -i '/^#line/d' *.c
            CONFIGURE_ARGS="--with-cflags='%{optflags}'" ruby extconf.rb
            make clean && make RPM_OPT_FLAGS="$RPM_OPT_FLAGS"
            make install RUBYARCHDIR="../../lib"
            mv ../../lib/${lexer_dir%/}.so .
            pushd  ../../lib
                ln -sf ../ext/${lexer_dir%/}/${lexer_dir%/}.so .
            popd
        popd
    done
    popd
    }

    test -d ffi-0.6.3/lib && {
    pushd  ffi-0.6.3/lib
        rm ffi_c.so
        ln -s ../ext/ffi_c/ffi_c.so .
    popd
    }

    # In repo as 1.2.5, rawhide 1.2.7
    pushd  thin-1.2.7/lib
        rm thin_parser.so
        ln -s ../ext/thin_parser/thin_parser.so .
    popd

    pushd bson_ext-1.1/ext/bson_ext
        rm cbson.so
        ln -s ../cbson/cbson.so .
    popd

    # In repo (0.10.4)
    pushd ruby-debug-base-0.10.3/lib
        rm ruby_debug.so
        ln -s ../ext/ruby_debug.so .
    popd

    #in repo
    pushd eventmachine-0.12.10/lib
       rm rubyeventmachine.so
       rm fastfilereaderext.so
       ln -s ../ext/rubyeventmachine.so .
       ln -s ../ext/fastfilereader/fastfilereaderext.so .
    popd

    # In repo
    pushd bcrypt-ruby-2.1.2/lib
        rm bcrypt_ext.so
        ln -s ../ext/mri/bcrypt_ext.so .
    popd

    # in repo
    pushd nokogiri-1.4.3.1/lib/nokogiri
        rm nokogiri.so
        ln -sf ../../ext/nokogiri/nokogiri.so .
    popd

    # in repo (rawhide)
    pushd json-1.4.6/ext/json/ext/json/ext
        rm generator.so
        ln -s ../../generator/generator.so
        rm parser.so
        ln -s ../../parser/parser.so .
    popd

    #in repo
    pushd linecache-0.43/lib/
        rm trace_nums.so
        ln -s ../ext/trace_nums.so .
    popd

    pushd em-http-request-*/lib
        rm em_buffer.so
        ln -s ../ext/buffer/em_buffer.so .
        rm http11_client.so
        ln -s ../ext/http11_client/http11_client.so .
    popd

    find . -name \*.css -print       | xargs chmod 644
    find . -name \*.js  -print       | xargs chmod 644
    find . -name \*.treetop -print   | xargs chmod 644
    find . -name \*.rdoc -print      | xargs chmod 644

    for f in $(find . -name \*.rb); do
      sed -i -e '/^#!/d' $f
      chmod 0644 $f
    done &> /dev/null
    find .  -perm /u+x  -type f -print0 |
        xargs --null sed -i 's|^#!/usr/local/bin/ruby|#!/usr/bin/ruby|'

    chmod 755 abstract-1.0.0/abstract.gemspec  || :
    chmod 755 cucumber-rails-0.3.2/templates/install/script/cucumber || :
    chmod 644 cucumber-rails-0.3.2/History.txt || :
    chmod 644 cucumber-rails-0.3.2/templates/install/step_definitions/capybara_steps.rb.erb || :
    chmod 644 ffi-0.6.3/ext/ffi_c/libffi/ltmain.sh || :
    chmod 644 gherkin-2.2.4/tasks/compile.rake || :
    chmod 644 i18n-0.4.1/MIT-LICENSE
    chmod 755 linecache-0.43/Rakefile || :
    chmod 755 mime-types-1.16/Rakefile || :
    chmod 755 mini_magick-2.1/test/not_an_image.php || :
    chmod 644 mini_magick-2.1/Rakefile || :
    chmod 644 mini_magick-2.1/MIT-LICENSE || :
    chmod 644 rack-1.2.1/test/cgi/lighttpd.conf || :
    chmod 755 rake-0.8.7/test/data/file_creation_task/Rakefile  || :
    chmod 755 rake-0.8.7/test/data/statusreturn/Rakefile || :
    chmod 755 ruby-debug-0.10.3/Rakefile || :
    chmod 755 ruby-debug-base-0.10.3/Rakefile || :
    for file in CHANGES VERSION README Rakefile; do
        chmod 644 term-ansicolor-1.0.5/$file || :
    done
    chmod 755 thin-1.2.7/lib/thin/controllers/service.sh.erb
    chmod 755 thin-1.2.7/example/async_chat.ru  || :
    chmod 755 thin-1.2.7/example/async_tailer.ru  || :
    chmod 644 treetop-1.4.8/spec/compiler/test_grammar.tt  || :
popd




%pre
getent group diaspora >/dev/null || groupadd -r diaspora
getent passwd diaspora >/dev/null ||        \
    useradd -r -g diaspora                  \
    -md  /var/lib/diaspora -s /bin/bash     \
    -c "Diaspora daemon" diaspora
exit 0


%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -fr $RPM_BUILD_ROOT

echo "ROOT:" $(pwd)

find . -name .git | xargs rm -rf
find . -name .gitignore -delete
find . -name \*.o -delete  || :

test -d gems/selenium-webdriver-0.0.28 && {
pushd  gems/selenium-webdriver-0.0.28/lib/selenium/webdriver/
%ifarch  %ix86 x86_64
%ifarch %ix86
   rm -rf firefox/native/linux/amd64
%else
   rm -rf firefox/native/linux/i386
%endif
%else
    rm -rf firefox/native/linux/i386
    rm -rf firefox/native/linux/amd64
%endif
popd
}

mkdir -p $RPM_BUILD_ROOT/%{_libdir}/diaspora-bundle
cp -ar  vendor/bundle  $RPM_BUILD_ROOT/%{_libdir}/diaspora-bundle

find  %{buildroot}/%{_libdir}/diaspora-bundle  \
    -type d  -fprintf dirs '%%%dir "%%p"\n'
find  -L %{buildroot}/%{_libdir}/diaspora-bundle  -regextype posix-awk \
    -type f -not -regex '.*[.]c$|.*[.]h$|.*[.]cpp$|.*Makefile$'        \
    -fprintf files '"%%p"\n'
find  %{buildroot}/%{_libdir}/diaspora-bundle -regextype posix-awk     \
    -type f -regex '.*[.]c$|.*[.]h$|.*[.]cpp$|.*Makefile$'             \
    -fprintf dev-files '"%%p"\n'
sed -i  -e 's|%{buildroot}||' -e 's|//|/|' files dev-files dirs
cat files >> dirs && cp dirs files

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -fr $RPM_BUILD_ROOT

%files -f files
%defattr(-, diaspora, diaspora, 0755)
%doc  COPYRIGHT Gemfile Gemfile.lock AUTHORS GNU-AGPL-3.0

%files -f dev-files devel
%defattr(-, root, root, 0644)
%doc COPYRIGHT AUTHORS GNU-AGPL-3.0

%changelog
* Sat Oct 02 2010 Alec Leamas  <leamas.alec@gmail.com>  0.0-1.1009271539_08b9aa8
  - Initial attempt to create a spec file
