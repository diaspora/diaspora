%global         debug_package %{nil} 
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
BuildArch:	noarch

# See http://github.com/diaspora/diaspora/issues/issue/393
Patch0:		source-fix.patch

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
getent passwd diaspora >/dev/null ||       \
    useradd -r -g diaspora                 \
    -md /usr/share/diaspora -s /sbin/nologin \
    -c "Diaspora daemon" diaspora
exit 0

%prep
%setup -q -n %{name}-%{version}-%{git_release}
pushd master 
%patch0 -p1
popd


mkdir master/tmp || :
#find . -name .git  | xargs rm -rf || :
find . -type f -exec \
    sed -i 's|^#!/usr/local/bin/ruby|#!/usr/bin/ruby|' {} \; > /dev/null

# Patch request: http://github.com/diaspora/diaspora/issues/issue/392
find . -name \*.css -print0 | xargs --null chmod 644
find . -name \*.js  -print0 | xargs --null chmod 644
chmod 644 master/public/stylesheets/brandongrotesque_light/Brandon_light-webfont.svg
chmod 644 master/public/stylesheets/brandongrotesque_light/demo.html

%build
rm -rf master/vendor/bundle
pushd  master
    tar cf public/source.tar  --exclude='source.tar' -X .gitignore *
popd

%install

[ "$RPM_BUILD_ROOT" != "/" ] && rm -fr $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_datadir}/diaspora
cp master/README.md .
mv master/GNU-AGPL-3.0 .

mkdir -p $RPM_BUILD_ROOT/%{_localstatedir}/log/diaspora
mkdir -p $RPM_BUILD_ROOT/etc/init.d
sed -i '/^cd /s|.*|cd %{_datadir}/diaspora/master|' diaspora-ws
cp diaspora-ws $RPM_BUILD_ROOT/etc/init.d
mkdir -p  $RPM_BUILD_ROOT/etc/logrotate.d
cp diaspora.logconf  $RPM_BUILD_ROOT/%{_sysconfdir}/logrotate.d/diaspora
mkdir -p $RPM_BUILD_ROOT/%{_datadir}/diaspora
cp -ar master $RPM_BUILD_ROOT/%{_datadir}/diaspora
cp master/.gitignore $RPM_BUILD_ROOT/%{_datadir}/diaspora/master

%post
/bin/chown diaspora:diaspora %{_localstatedir}/log/diaspora
ln -sf  %{_localstatedir}/log/diaspora \
        %{_datadir}/diaspora/master/log || :
ln -sf %{_libdir}/diaspora-bundle/master/vendor/bundle \
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
%{_localstatedir}/log/diaspora
%config(noreplace) %{_sysconfdir}/logrotate.d/diaspora
%{_sysconfdir}/init.d/diaspora-ws

%changelog
* Fri Sep 24 2010 Alec Leamas  <leamas.alec@gmail.com>       1.1009280542_859ec2d
  - Initial attempt to create a spec file
