# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{json}
  s.version = "1.5.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Florian Frank}]
  s.date = %q{2011-06-20}
  s.description = %q{This is a JSON implementation as a Ruby extension in C.}
  s.email = %q{flori@ping.de}
  s.executables = [%q{edit_json.rb}, %q{prettify_json.rb}]
  s.extensions = [%q{ext/json/ext/parser/extconf.rb}, %q{ext/json/ext/generator/extconf.rb}]
  s.extra_rdoc_files = [%q{README.rdoc}]
  s.files = [%q{tests}, %q{tests/test_json_string_matching.rb}, %q{tests/test_json_fixtures.rb}, %q{tests/setup_variant.rb}, %q{tests/fixtures}, %q{tests/fixtures/fail6.json}, %q{tests/fixtures/fail9.json}, %q{tests/fixtures/fail10.json}, %q{tests/fixtures/fail24.json}, %q{tests/fixtures/fail28.json}, %q{tests/fixtures/fail13.json}, %q{tests/fixtures/fail4.json}, %q{tests/fixtures/pass3.json}, %q{tests/fixtures/fail11.json}, %q{tests/fixtures/fail14.json}, %q{tests/fixtures/fail3.json}, %q{tests/fixtures/fail12.json}, %q{tests/fixtures/pass16.json}, %q{tests/fixtures/pass15.json}, %q{tests/fixtures/fail20.json}, %q{tests/fixtures/fail8.json}, %q{tests/fixtures/pass2.json}, %q{tests/fixtures/fail5.json}, %q{tests/fixtures/fail1.json}, %q{tests/fixtures/fail25.json}, %q{tests/fixtures/pass17.json}, %q{tests/fixtures/fail7.json}, %q{tests/fixtures/pass26.json}, %q{tests/fixtures/fail21.json}, %q{tests/fixtures/pass1.json}, %q{tests/fixtures/fail23.json}, %q{tests/fixtures/fail18.json}, %q{tests/fixtures/fail2.json}, %q{tests/fixtures/fail22.json}, %q{tests/fixtures/fail27.json}, %q{tests/fixtures/fail19.json}, %q{tests/test_json_unicode.rb}, %q{tests/test_json_addition.rb}, %q{tests/test_json_generate.rb}, %q{tests/test_json_encoding.rb}, %q{tests/test_json.rb}, %q{COPYING}, %q{TODO}, %q{Rakefile}, %q{benchmarks}, %q{benchmarks/data-p4-3GHz-ruby18}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkExt#parser.dat}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkPure.log}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkYAML.log}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkRails.log}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkRails.log}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_safe.dat}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkYAML#parser.dat}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkRails#generator.dat}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure.log}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_pretty-autocorrelation.dat}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkPure#parser-autocorrelation.dat}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkExt#parser-autocorrelation.dat}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkPure#parser.dat}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkRails#parser-autocorrelation.dat}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkExt.log}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_fast.dat}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_safe.dat}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_pretty.dat}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkComparison.log}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkRails#parser.dat}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt.log}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_safe-autocorrelation.dat}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkRails#generator-autocorrelation.dat}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_fast-autocorrelation.dat}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_pretty.dat}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_fast-autocorrelation.dat}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkPure#generator_fast.dat}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkComparison.log}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_pretty-autocorrelation.dat}, %q{benchmarks/data-p4-3GHz-ruby18/ParserBenchmarkYAML#parser-autocorrelation.dat}, %q{benchmarks/data-p4-3GHz-ruby18/GeneratorBenchmarkExt#generator_safe-autocorrelation.dat}, %q{benchmarks/parser2_benchmark.rb}, %q{benchmarks/parser_benchmark.rb}, %q{benchmarks/generator2_benchmark.rb}, %q{benchmarks/generator_benchmark.rb}, %q{benchmarks/ohai.ruby}, %q{benchmarks/data}, %q{benchmarks/ohai.json}, %q{lib}, %q{lib/json}, %q{lib/json/json.xpm}, %q{lib/json/TrueClass.xpm}, %q{lib/json/version.rb}, %q{lib/json/Array.xpm}, %q{lib/json/add}, %q{lib/json/add/core.rb}, %q{lib/json/add/rails.rb}, %q{lib/json/common.rb}, %q{lib/json/pure}, %q{lib/json/pure/generator.rb}, %q{lib/json/pure/parser.rb}, %q{lib/json/ext.rb}, %q{lib/json/pure.rb}, %q{lib/json/Key.xpm}, %q{lib/json/FalseClass.xpm}, %q{lib/json/editor.rb}, %q{lib/json/Numeric.xpm}, %q{lib/json/ext}, %q{lib/json/ext/1.9}, %q{lib/json/ext/1.8}, %q{lib/json/NilClass.xpm}, %q{lib/json/String.xpm}, %q{lib/json/Hash.xpm}, %q{lib/json.rb}, %q{Gemfile}, %q{README.rdoc}, %q{json_pure.gemspec}, %q{GPL}, %q{CHANGES}, %q{bin}, %q{bin/prettify_json.rb}, %q{bin/edit_json.rb}, %q{COPYING-json-jruby}, %q{ext}, %q{ext/json}, %q{ext/json/ext}, %q{ext/json/ext/parser}, %q{ext/json/ext/parser/parser.h}, %q{ext/json/ext/parser/extconf.rb}, %q{ext/json/ext/parser/parser.rl}, %q{ext/json/ext/parser/parser.c}, %q{ext/json/ext/generator}, %q{ext/json/ext/generator/generator.c}, %q{ext/json/ext/generator/extconf.rb}, %q{ext/json/ext/generator/generator.h}, %q{VERSION}, %q{data}, %q{data/prototype.js}, %q{data/index.html}, %q{data/example.json}, %q{json.gemspec}, %q{java}, %q{java/src}, %q{java/src/json}, %q{java/src/json/ext}, %q{java/src/json/ext/Parser.java}, %q{java/src/json/ext/RuntimeInfo.java}, %q{java/src/json/ext/GeneratorState.java}, %q{java/src/json/ext/OptionsReader.java}, %q{java/src/json/ext/ParserService.java}, %q{java/src/json/ext/Parser.rl}, %q{java/src/json/ext/StringEncoder.java}, %q{java/src/json/ext/GeneratorService.java}, %q{java/src/json/ext/Utils.java}, %q{java/src/json/ext/StringDecoder.java}, %q{java/src/json/ext/Generator.java}, %q{java/src/json/ext/ByteListTranscoder.java}, %q{java/src/json/ext/GeneratorMethods.java}, %q{java/lib}, %q{java/lib/bytelist-1.0.6.jar}, %q{java/lib/jcodings.jar}, %q{diagrams}, %q{README-json-jruby.markdown}, %q{install.rb}, %q{json-java.gemspec}, %q{tools}, %q{tools/fuzz.rb}, %q{tools/server.rb}, %q{./tests/test_json_string_matching.rb}, %q{./tests/test_json_fixtures.rb}, %q{./tests/test_json_unicode.rb}, %q{./tests/test_json_addition.rb}, %q{./tests/test_json_generate.rb}, %q{./tests/test_json_encoding.rb}, %q{./tests/test_json.rb}]
  s.homepage = %q{http://flori.github.com/json}
  s.rdoc_options = [%q{--title}, %q{JSON implemention for Ruby}, %q{--main}, %q{README.rdoc}]
  s.require_paths = [%q{ext/json/ext}, %q{ext}, %q{lib}]
  s.rubyforge_project = %q{json}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{JSON Implementation for Ruby}
  s.test_files = [%q{./tests/test_json_string_matching.rb}, %q{./tests/test_json_fixtures.rb}, %q{./tests/test_json_unicode.rb}, %q{./tests/test_json_addition.rb}, %q{./tests/test_json_generate.rb}, %q{./tests/test_json_encoding.rb}, %q{./tests/test_json.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<permutation>, [">= 0"])
      s.add_development_dependency(%q<bullshit>, [">= 0"])
      s.add_development_dependency(%q<sdoc>, [">= 0"])
    else
      s.add_dependency(%q<permutation>, [">= 0"])
      s.add_dependency(%q<bullshit>, [">= 0"])
      s.add_dependency(%q<sdoc>, [">= 0"])
    end
  else
    s.add_dependency(%q<permutation>, [">= 0"])
    s.add_dependency(%q<bullshit>, [">= 0"])
    s.add_dependency(%q<sdoc>, [">= 0"])
  end
end
