# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{net-sftp}
  s.version = "2.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jamis Buck"]
  s.date = %q{2010-08-19}
  s.description = %q{A pure Ruby implementation of the SFTP client protocol}
  s.email = %q{netsftp@solutious.com}
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "lib/net/sftp/constants.rb", "lib/net/sftp/errors.rb", "lib/net/sftp/operations/dir.rb", "lib/net/sftp/operations/download.rb", "lib/net/sftp/operations/file.rb", "lib/net/sftp/operations/file_factory.rb", "lib/net/sftp/operations/upload.rb", "lib/net/sftp/packet.rb", "lib/net/sftp/protocol/01/attributes.rb", "lib/net/sftp/protocol/01/base.rb", "lib/net/sftp/protocol/01/name.rb", "lib/net/sftp/protocol/02/base.rb", "lib/net/sftp/protocol/03/base.rb", "lib/net/sftp/protocol/04/attributes.rb", "lib/net/sftp/protocol/04/base.rb", "lib/net/sftp/protocol/04/name.rb", "lib/net/sftp/protocol/05/base.rb", "lib/net/sftp/protocol/06/attributes.rb", "lib/net/sftp/protocol/06/base.rb", "lib/net/sftp/protocol/base.rb", "lib/net/sftp/protocol.rb", "lib/net/sftp/request.rb", "lib/net/sftp/response.rb", "lib/net/sftp/session.rb", "lib/net/sftp/version.rb", "lib/net/sftp.rb", "README.rdoc"]
  s.files = ["CHANGELOG.rdoc", "lib/net/sftp/constants.rb", "lib/net/sftp/errors.rb", "lib/net/sftp/operations/dir.rb", "lib/net/sftp/operations/download.rb", "lib/net/sftp/operations/file.rb", "lib/net/sftp/operations/file_factory.rb", "lib/net/sftp/operations/upload.rb", "lib/net/sftp/packet.rb", "lib/net/sftp/protocol/01/attributes.rb", "lib/net/sftp/protocol/01/base.rb", "lib/net/sftp/protocol/01/name.rb", "lib/net/sftp/protocol/02/base.rb", "lib/net/sftp/protocol/03/base.rb", "lib/net/sftp/protocol/04/attributes.rb", "lib/net/sftp/protocol/04/base.rb", "lib/net/sftp/protocol/04/name.rb", "lib/net/sftp/protocol/05/base.rb", "lib/net/sftp/protocol/06/attributes.rb", "lib/net/sftp/protocol/06/base.rb", "lib/net/sftp/protocol/base.rb", "lib/net/sftp/protocol.rb", "lib/net/sftp/request.rb", "lib/net/sftp/response.rb", "lib/net/sftp/session.rb", "lib/net/sftp/version.rb", "lib/net/sftp.rb", "Rakefile", "README.rdoc", "setup.rb", "test/common.rb", "test/protocol/01/test_attributes.rb", "test/protocol/01/test_base.rb", "test/protocol/01/test_name.rb", "test/protocol/02/test_base.rb", "test/protocol/03/test_base.rb", "test/protocol/04/test_attributes.rb", "test/protocol/04/test_base.rb", "test/protocol/04/test_name.rb", "test/protocol/05/test_base.rb", "test/protocol/06/test_attributes.rb", "test/protocol/06/test_base.rb", "test/protocol/test_base.rb", "test/test_all.rb", "test/test_dir.rb", "test/test_download.rb", "test/test_file.rb", "test/test_file_factory.rb", "test/test_packet.rb", "test/test_protocol.rb", "test/test_request.rb", "test/test_response.rb", "test/test_session.rb", "test/test_upload.rb", "Manifest", "net-sftp.gemspec"]
  s.homepage = %q{http://net-ssh.rubyforge.org/sftp}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Net-sftp", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{net-ssh}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A pure Ruby implementation of the SFTP client protocol}
  s.test_files = ["test/test_all.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<net-ssh>, [">= 2.0.9"])
    else
      s.add_dependency(%q<net-ssh>, [">= 2.0.9"])
    end
  else
    s.add_dependency(%q<net-ssh>, [">= 2.0.9"])
  end
end
