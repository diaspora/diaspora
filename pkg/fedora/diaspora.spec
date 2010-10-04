# 
#  Build diaspora RPM package.
#
#  Packages current HEAD if the diaspora master branch
#  to a reasonable Fedora RPM.
#
#  If the environment variable GIT_VERSION is set, builds an rpm
#  from this version (i. e., uses this commit).
#
%define         git_release     HEAD

Summary:        A social network server
Name:           diaspora
Version:        0.0.1
Release:        1.%{git_release}%{?dist}
License:        AGPLv3 
Group:          Applications/Communications
URL:            http://www.joindiaspora.com/
Vendor:         joindiaspora.com
Source:         %{name}-%{version}-%{git_release}.tar.gz
Source1:        diaspora-ws
#BuildRoot:      %{_tmppath}/root-%{name}-%{version}
#Prefix:         %{_prefix}

BuildRequires:  git
Requires(pre):  shadow-utils
Requires:       mongodb-server
Requires:       ruby(abi) = 1.8
Requires:       diaspora-bundle = %{version}

%description
A privacy aware, personally controlled, do-it-all and
open source social network server.

%pre
getent group diaspora >/dev/null || groupadd -r diaspora
getent passwd diaspora >/dev/null ||   \
    useradd -r -g diaspora             \
    -md /var/diaspora -s /sbin/nologin \
    -c "Diaspora daemon" diaspora
exit 0

%prep
%setup -q -n %{name}-%{version}-%{git_release}
mkdir diaspora/tmp || :

%build
find . -name .git* -execdir rm -rf {} \; || :
#find . -name test -execdir rm -rf {} \; || : > /dev/null 2>&1
find . -name \*.css -exec  chmod 644 {} \;
find . -name \*.js -exec  chmod 644 {} \;
#find . -name \*.treetop -exec  chmod 644 {} \;
find . -name \*.rdoc -exec  chmod 644 {} \;
#find . -name Rakefile -exec  chmod 755  {} \;
#for f in $(find . -name \*.rb); do
#  sed -i -e '/^#!/d' $f
#  chmod 0644 $f
#done > /dev/null 2>&1
find . -type f -exec \
    sed -i 's/^#!\/usr\/local\/bin\/ruby/#!\/usr\/bin\/ruby/g' {} \; > /dev/null

chmod 644 master/public/stylesheets/brandongrotesque_light/demo.html
chmod 644 master/public/stylesheets/brandongrotesque_light/Brandon_light-webfont.svg
sed -i -e "s|\r||" master/public/javascripts/jquery.cycle/src/jquery.cycle.lite.js
sed -i -e "s|\r||" master/public/javascripts/fancybox/jquery.fancybox-1.3.1.js


%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -fr $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_datadir}/diaspora
mkdir -p $RPM_BUILD_ROOT/%{_libdir}/diaspora/master/vendor
cp master/README.md .
mv master/GNU-AGPL-3.0 .

sed -i '/^cd /s|.*|cd %{_datadir}/diaspora/master|' diaspora-ws
mkdir -p $RPM_BUILD_ROOT/%{_localstatedir}/log/diaspora
mkdir -p $RPM_BUILD_ROOT/etc/init.d
cp diaspora-ws $RPM_BUILD_ROOT/etc/init.d
mkdir -p  $RPM_BUILD_ROOT/etc/logrotate.d
cp diaspora  $RPM_BUILD_ROOT/etc/logrotate.d

%post
/bin/chown diaspora:diaspora %{_localstatedir}/log/diaspora
ln -sf  %{_localstatedir}/log/diaspora \
        %{_datadir}/diaspora/master/log || :
ln -sf %{_libdir}/diaspora/master/vendor/bundle \
       %{_datadir}/diaspora/master/vendor || :
/sbin/chkconfig --add  diaspora-ws

%preun
if [ $1 -eq 0 ] ; then
    service diaspora-ws stop  >/dev/null 2>&1 || :
    /sbin/chkconfig --del  diaspora-ws
fi

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -fr $RPM_BUILD_ROOT

%files
%defattr(-, root, root, 0755)
%doc  README.md GNU-AGPL-3.0
%{_datadir}/diaspora
%{_libdir}/diaspora
%{_localstatedir}/log/diaspora
%config(noreplace) %{_sysconfdir}/logrotate.d/diaspora
%{_sysconfdir}/init.d/diaspora-ws

%changelog
* Fri Sep 24 2010 Alec Leamas  <leamas.alec@gmail.com>       1.1009280542_859ec2d
  - Initial attempt to create a spec file
