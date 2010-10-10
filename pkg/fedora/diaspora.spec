%global         debug_package   %{nil} 
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

Requires:       mongodb-server
Requires:       ruby(abi) = 1.8
Requires:       diaspora-bundle = %{version}


%description
A privacy aware, personally controlled, do-it-all and
open source social network server.

%prep
%setup -q -n %{name}-%{version}-%{git_release}

find .  -perm /u+x -type f -exec \
    sed -i 's|^#!/usr/local/bin/ruby|#!/usr/bin/ruby|' {} \; > /dev/null

%build
rm -rf master/vendor/bundle
mkdir master/tmp || :
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
cp -ar master/.gitignore master/.bundle $RPM_BUILD_ROOT/%{_datadir}/diaspora/master
cp diaspora-setup  $RPM_BUILD_ROOT/%{_datadir}/diaspora
mkdir -p $RPM_BUILD_ROOT/%{_localstatedir}/lib/diaspora/uploads
mkdir -p $RPM_BUILD_ROOT/%{_localstatedir}/lib/diaspora/tmp

find  $RPM_BUILD_ROOT/%{_datadir}/diaspora  -type d  -fprintf dirs '%%%dir "%%p"\n'
find  -L $RPM_BUILD_ROOT/%{_datadir}/diaspora  -type f -fprintf files '"%%p"\n'
cat files >> dirs && mv -f dirs files
sed -i   -e '\|.*/master/config.ru"$|d'                    \
         -e '\|.*/master/config/environment.rb"$|d'        \
         -e 's|%{buildroot}||' -e 's|//|/|' -e '/""/d'     \
      files


%post
rm -f  %{_datadir}/diaspora/master/vendor/bundle
rm -f  %{_datadir}/diaspora/master/log
rm -f  %{_datadir}/diaspora/master/public/uploads
rm -rf  %{_datadir}/diaspora/master/tmp

ln -s  %{_localstatedir}/log/diaspora \
        %{_datadir}/diaspora/master/log || :
ln -s  %{_libdir}/diaspora-bundle/master/vendor/bundle \
       %{_datadir}/diaspora/master/vendor || :
ln -s  %{_localstatedir}/lib/diaspora/uploads \
       %{_datadir}/diaspora/master/public/uploads || :
ln -s  %{_localstatedir}/lib/diaspora/tmp \
       %{_datadir}/diaspora/master/tmp || :
/sbin/chkconfig --add  diaspora-ws || :

%preun
if [ $1 -eq 0 ] ; then
    service diaspora-ws stop  >/dev/null 2>&1 || :
    /sbin/chkconfig --del  diaspora-ws
fi

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -fr $RPM_BUILD_ROOT

%files -f files
%defattr(-, root, root, 0755)
%doc  README.md GNU-AGPL-3.0
%attr(-, diaspora, diaspora) %{_datadir}/diaspora/master/config.ru
%attr(-, diaspora, diaspora) %{_datadir}/diaspora/master/config/environment.rb
%attr(-, diaspora, diaspora) %{_localstatedir}/log/diaspora
%attr(-, diaspora, diaspora) %{_localstatedir}/lib/diaspora/uploads
%attr(-, diaspora, diaspora) %{_localstatedir}/lib/diaspora/tmp
%config(noreplace) %{_sysconfdir}/logrotate.d/diaspora
%{_sysconfdir}/init.d/diaspora-ws

%changelog
* Fri Sep 24 2010 Alec Leamas  <leamas.alec@gmail.com>  0.0-1.1009280542_859ec2d
  - Initial attempt to create a spec fi+le

# rubygem-term-ansicolor  in repo (1.0.5)
# rubygem-abstract:       in repo (1.0)
# rubygem-actionpack      in repo (2.3.5), rawhide (2.3.8)
# rubygem-builder         in repo (2.1.2)
# rubygem-columnize       in repo (0.3.1)
# rubygem-crack           in repo (0.1.8)
# rubygem-cucumber        in repo (0.9.0)
# diff-lcs                in rep  (1.1.2)
# eventmachine            in repo (0.12.10)
# gherkin                 in repo (2.2.4)
# rubygem-json            in repo (1.1.9), rawhide(1.4.6)
# rubygem-linecache       in repo (0.43)
# rubygem-mime-types      in repo (1.16)
# rubygem-mocha           in repo (0.9.8)
# rubygem-net-ssh         in repo (2.0.23)
# rubygem-nokogiri        in repo (1.4.3.1)
# rubygem-rake            in repo (0.8.7)
# rubygem-ruby-debug      in repo (0.10.4)
# rubygem-ruby-debug-base in repo (0.10.4)
# rubygem-term-ansicolor  in repo (1.0.5)
# rubygem-thin            in repo(1.2.5), rawhide(1.2.7)
# rubygem-uuidtools       in repo(2.1.1)
