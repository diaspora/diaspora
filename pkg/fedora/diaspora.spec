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
Source2:        diaspora-setup
BuildArch:      noarch

# See http://github.com/diaspora/diaspora/issues/issue/393
Patch0:         source-fix.patch

BuildRequires:  git

Requires(pre):  shadow-utils
Requires:       mongodb-server
Requires:       ruby(abi) = 1.8
Requires:       diaspora-bundle = %{version}

%description
A privacy aware, personally controlled, do-it-all and
open source social network server.

%prep
%setup -q -n %{name}-%{version}-%{git_release}
pushd master 
%patch0 -p1

# See: http://github.com/diaspora/diaspora/issues/issue/392
git apply %{_sourcedir}/perm-fix.patch
popd
find .  -perm /u+x -type f -exec \
    sed -i 's|^#!/usr/local/bin/ruby|#!/usr/bin/ruby|' {} \; > /dev/null

%build
rm -rf master/vendor/bundle
mkdir master/tmp || :
pushd  master
    tar cf public/source.tar  --exclude='source.tar' -X .gitignore *
popd

%pre
getent group diaspora >/dev/null || groupadd -r diaspora
getent passwd diaspora >/dev/null ||       \
    useradd -r -g apache                 \
    -md /usr/share/diaspora -s /sbin/nologin \
    -c "Diaspora daemon" diaspora
exit 0

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
cp diaspora-setup  $RPM_BUILD_ROOT/%{_datadir}/diaspora
mkdir -p $RPM_BUILD_ROOT/%{_localstatedir}/lib/diaspora/uploads

%post
rm -f  %{_datadir}/diaspora/master/vendor/bundle
rm -f  %{_datadir}/diaspora/master/log
rm -f  %{_datadir}/diaspora/master/public/uploads

ln -s  %{_localstatedir}/log/diaspora \
        %{_datadir}/diaspora/master/log || :
ln -s  %{_libdir}/diaspora-bundle/master/vendor/bundle \
       %{_datadir}/diaspora/master/vendor || :
ln -s  %{_localstatedir}/lib/diaspora/uploads \
       %{_datadir}/diaspora/master/public/uploads || :
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
%attr(0555, diaspora, diaspora) %{_datadir}/diaspora
%attr(-, diaspora, diaspora) %{_localstatedir}/log/diaspora
%attr(-, diaspora, diaspora) %{_localstatedir}/lib/diaspora/uploads
%config(noreplace) %{_sysconfdir}/logrotate.d/diaspora
%{_sysconfdir}/init.d/diaspora-ws

%changelog
* Fri Sep 24 2010 Alec Leamas  <leamas.alec@gmail.com>       1.1009280542_859ec2d
  - Initial attempt to create a spec file
