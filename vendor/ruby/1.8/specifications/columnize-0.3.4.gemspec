# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{columnize}
  s.version = "0.3.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["R. Bernstein"]
  s.date = %q{2011-07-05}
  s.description = %q{
In showing a long lists, sometimes one would prefer to see the value
arranged aligned in columns. Some examples include listing methods
of an object or debugger commands. 

An Example:
```
require "columnize"
  Columnize.columnize((1..100).to_a, :displaywidth=>60)
  puts Columnize.columnize((1..100).to_a, :displaywidth=>60)
  1   8  15  22  29  36  43  50  57  64  71  78  85  92   99
  2   9  16  23  30  37  44  51  58  65  72  79  86  93  100
  3  10  17  24  31  38  45  52  59  66  73  80  87  94
  4  11  18  25  32  39  46  53  60  67  74  81  88  95
  5  12  19  26  33  40  47  54  61  68  75  82  89  96
  6  13  20  27  34  41  48  55  62  69  76  83  90  97
  7  14  21  28  35  42  49  56  63  70  77  84  91  98

  See Examples in the rdoc documentation for more examples.
```
}
  s.email = %q{rockyb@rubyforge.net}
  s.extra_rdoc_files = ["README", "lib/columnize.rb", "COPYING"]
  s.files = [".gitignore", "AUTHORS", "COPYING", "ChangeLog", "Makefile", "NEWS", "README", "Rakefile", "columnize.gemspec", "lib/Makefile", "lib/columnize.rb", "lib/version.rb", "test/test-columnize.rb", "test/test-hashparm.rb"]
  s.homepage = %q{https://github.com/rocky/columnize}
  s.licenses = ["Ruby", "GPL2"]
  s.rdoc_options = ["--verbose", "--main", "README", "--title", "Columnize 0.3.4 Documentation"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.2")
  s.rubyforge_project = %q{columnize}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Module to format an Array as an Array of String aligned in columns}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
