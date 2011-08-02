# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{multipart-post}
  s.version = "1.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Sieger"]
  s.date = %q{2011-07-25}
  s.description = %q{Use with Net::HTTP to do multipart form posts.  IO values that have #content_type, #original_filename, and #local_path will be posted as a binary file.}
  s.email = %q{nick@nicksieger.com}
  s.extra_rdoc_files = ["Manifest.txt", "README.txt"]
  s.files = ["lib/composite_io.rb", "lib/multipartable.rb", "lib/parts.rb", "lib/net/http/post/multipart.rb", "Manifest.txt", "Rakefile", "README.txt", "test/test_composite_io.rb", "test/net/http/post/test_multipart.rb", "test/test_parts.rb"]
  s.homepage = %q{http://github.com/nicksieger/multipart-post}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{caldersphere}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Creates a multipart form post accessory for Net::HTTP.}
  s.test_files = ["test/net/http/post/test_multipart.rb", "test/test_composite_io.rb", "test/test_parts.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
