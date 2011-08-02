# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{net-ldap}
  s.version = "0.2.20110317223538"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Francis Cianfrocca", "Emiel van de Laar", "Rory O'Connell", "Kaspar Schiess", "Austin Ziegler"]
  s.date = %q{2011-03-17}
  s.description = %q{Net::LDAP for Ruby (also called net-ldap) implements client access for the
Lightweight Directory Access Protocol (LDAP), an IETF standard protocol for
accessing distributed directory services. Net::LDAP is written completely in
Ruby with no external dependencies. It supports most LDAP client features and a
subset of server features as well.

Net::LDAP has been tested against modern popular LDAP servers including
OpenLDAP and Active Directory. The current release is mostly compliant with
earlier versions of the IETF LDAP RFCs (2251–2256, 2829–2830, 3377, and 3771).
Our roadmap for Net::LDAP 1.0 is to gain full <em>client</em> compliance with
the most recent LDAP RFCs (4510–4519, plutions of 4520–4532).}
  s.email = ["blackhedd@rubyforge.org", "gemiel@gmail.com", "rory.ocon@gmail.com", "kaspar.schiess@absurd.li", "austin@rubyforge.org"]
  s.extra_rdoc_files = ["Manifest.txt", "Contributors.rdoc", "Hacking.rdoc", "History.rdoc", "License.rdoc", "README.rdoc"]
  s.files = [".autotest", ".rspec", "Contributors.rdoc", "Hacking.rdoc", "History.rdoc", "License.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "autotest/discover.rb", "lib/net-ldap.rb", "lib/net/ber.rb", "lib/net/ber/ber_parser.rb", "lib/net/ber/core_ext.rb", "lib/net/ber/core_ext/array.rb", "lib/net/ber/core_ext/bignum.rb", "lib/net/ber/core_ext/false_class.rb", "lib/net/ber/core_ext/fixnum.rb", "lib/net/ber/core_ext/string.rb", "lib/net/ber/core_ext/true_class.rb", "lib/net/ldap.rb", "lib/net/ldap/dataset.rb", "lib/net/ldap/dn.rb", "lib/net/ldap/entry.rb", "lib/net/ldap/filter.rb", "lib/net/ldap/password.rb", "lib/net/ldap/pdu.rb", "lib/net/snmp.rb", "net-ldap.gemspec", "spec/integration/ssl_ber_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/unit/ber/ber_spec.rb", "spec/unit/ber/core_ext/string_spec.rb", "spec/unit/ldap/dn_spec.rb", "spec/unit/ldap/entry_spec.rb", "spec/unit/ldap/filter_spec.rb", "spec/unit/ldap_spec.rb", "test/common.rb", "test/test_entry.rb", "test/test_filter.rb", "test/test_ldap_connection.rb", "test/test_ldif.rb", "test/test_password.rb", "test/test_rename.rb", "test/test_snmp.rb", "test/testdata.ldif", "testserver/ldapserver.rb", "testserver/testdata.ldif", ".gemtest"]
  s.homepage = %q{http://net-ldap.rubyforge.org/}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = %q{net-ldap}
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{Net::LDAP for Ruby (also called net-ldap) implements client access for the Lightweight Directory Access Protocol (LDAP), an IETF standard protocol for accessing distributed directory services}
  s.test_files = ["test/test_entry.rb", "test/test_filter.rb", "test/test_ldap_connection.rb", "test/test_ldif.rb", "test/test_password.rb", "test/test_rename.rb", "test/test_snmp.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe-git>, ["~> 1"])
      s.add_development_dependency(%q<hoe-gemspec>, ["~> 1"])
      s.add_development_dependency(%q<metaid>, ["~> 1"])
      s.add_development_dependency(%q<flexmock>, ["~> 0.9.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<hoe>, [">= 2.9.1"])
    else
      s.add_dependency(%q<hoe-git>, ["~> 1"])
      s.add_dependency(%q<hoe-gemspec>, ["~> 1"])
      s.add_dependency(%q<metaid>, ["~> 1"])
      s.add_dependency(%q<flexmock>, ["~> 0.9.0"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<hoe>, [">= 2.9.1"])
    end
  else
    s.add_dependency(%q<hoe-git>, ["~> 1"])
    s.add_dependency(%q<hoe-gemspec>, ["~> 1"])
    s.add_dependency(%q<metaid>, ["~> 1"])
    s.add_dependency(%q<flexmock>, ["~> 0.9.0"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<hoe>, [">= 2.9.1"])
  end
end
