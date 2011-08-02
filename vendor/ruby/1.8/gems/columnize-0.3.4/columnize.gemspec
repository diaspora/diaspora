# -*- Ruby -*-
# -*- encoding: utf-8 -*-
require 'rake'
require 'rubygems' unless 
  Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/version" unless 
  Object.const_defined?(:'Columnize')

Gem::Specification.new do |spec|
  spec.authors      = ['R. Bernstein']
  spec.date         = Time.now
  spec.description  = '
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
'
  spec.email        = 'rockyb@rubyforge.net'
  spec.files        = `git ls-files`.split("\n")
  spec.homepage     = 'https://github.com/rocky/columnize'
  spec.name         = 'columnize'
  spec.licenses     = ['Ruby', 'GPL2']
  spec.platform     = Gem::Platform::RUBY
  spec.require_path = 'lib'
  spec.required_ruby_version = '>= 1.8.2'
  spec.rubyforge_project = 'columnize'
  spec.summary      = 'Module to format an Array as an Array of String aligned in columns'
  spec.version      = Columnize::VERSION
  spec.has_rdoc     = true
  spec.extra_rdoc_files = %w(README lib/columnize.rb COPYING)

  # Make the readme file the start page for the generated html
  spec.rdoc_options += %w(--verbose --main README)
  spec.rdoc_options += ['--title', "Columnize #{Columnize::VERSION} Documentation"]

end
