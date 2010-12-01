# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rubyzip}
  s.version = "0.9.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Thomas Sondergaard"]
  s.date = %q{2010-01-01}
  s.email = %q{thomas(at)sondergaard.cc}
  s.files = ["README", "NEWS", "TODO", "ChangeLog", "install.rb", "Rakefile", "samples/example.rb", "samples/gtkRubyzip.rb", "samples/write_simple.rb", "samples/zipfind.rb", "samples/example_filesystem.rb", "samples/qtzip.rb", "test/stdrubyexttest.rb", "test/alltests.rb", "test/ziptest.rb", "test/ioextrastest.rb", "test/ziprequiretest.rb", "test/zipfilesystemtest.rb", "test/gentestfiles.rb", "test/data/rubycode2.zip", "test/data/file1.txt", "test/data/testDirectory.bin", "test/data/zipWithDirs.zip", "test/data/file2.txt", "test/data/file1.txt.deflatedData", "test/data/notzippedruby.rb", "test/data/rubycode.zip", "lib/zip/zipfilesystem.rb", "lib/zip/stdrubyext.rb", "lib/zip/tempfile_bugfixed.rb", "lib/zip/ioextras.rb", "lib/zip/zip.rb", "lib/zip/ziprequire.rb"]
  s.homepage = %q{http://rubyzip.sourceforge.net/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{rubyzip is a ruby module for reading and writing zip files}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
