# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rcov}
  s.version = "0.9.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Relevance", "Chad Humphries (spicycode)", "Aaron Bedra (abedra)", "Jay McGaffigan(hooligan495)", "Mauricio Fernandez"]
  s.cert_chain = nil
  s.date = %q{2009-12-29}
  s.default_executable = %q{rcov}
  s.description = %q{rcov is a code coverage tool for Ruby. It is commonly used for viewing overall test unit coverage of target code.  It features fast execution (20-300 times faster than previous tools), multiple analysis modes, XHTML and several kinds of text reports, easy automation with Rake via a RcovTask, fairly accurate coverage information through code linkage inference using simple heuristics, colorblind-friendliness...}
  s.email = %q{opensource@thinkrelevance.com}
  s.executables = ["rcov"]
  s.extensions = ["ext/rcovrt/extconf.rb"]
  s.files = ["bin/rcov", "lib/rcov.rb", "lib/rcov/lowlevel.rb", "lib/rcov/version.rb", "lib/rcov/rcovtask.rb", "lib/rcov/formatters.rb", "lib/rcov/call_site_analyzer.rb", "lib/rcov/code_coverage_analyzer.rb", "lib/rcov/coverage_info.rb", "lib/rcov/differential_analyzer.rb", "lib/rcov/file_statistics.rb", "lib/rcov/formatters/base_formatter.rb", "lib/rcov/formatters/full_text_report.rb", "lib/rcov/formatters/html_erb_template.rb", "lib/rcov/formatters/html_coverage.rb", "lib/rcov/formatters/text_coverage_diff.rb", "lib/rcov/formatters/text_report.rb", "lib/rcov/formatters/text_summary.rb", "lib/rcov/formatters/failure_report.rb", "lib/rcov/templates/index.html.erb", "lib/rcov/templates/detail.html.erb", "lib/rcov/templates/screen.css", "lib/rcov/templates/print.css", "lib/rcov/templates/rcov.js", "lib/rcov/templates/jquery-1.3.2.min.js", "lib/rcov/templates/jquery.tablesorter.min.js", "ext/rcovrt/extconf.rb", "ext/rcovrt/1.8/rcovrt.c", "ext/rcovrt/1.9/rcovrt.c", "ext/rcovrt/1.8/callsite.c", "ext/rcovrt/1.9/callsite.c", "LICENSE", "Rakefile", "doc/readme_for_rake.markdown", "doc/readme_for_vim.markdown", "doc/readme_for_emacs.markdown", "doc/readme_for_api.markdown", "THANKS", "test/functional_test.rb", "test/file_statistics_test.rb", "test/assets/sample_03.rb", "test/assets/sample_05-new.rb", "test/code_coverage_analyzer_test.rb", "test/assets/sample_04.rb", "test/assets/sample_02.rb", "test/assets/sample_05-old.rb", "test/assets/sample_01.rb", "test/turn_off_rcovrt.rb", "test/call_site_analyzer_test.rb", "test/assets/sample_05.rb", "test/assets/sample_06.rb", "editor-extensions/rcov.vim", "test/test_helper.rb", "test/expected_coverage/diff-gcc-all.out", "test/expected_coverage/diff-gcc-diff.out", "test/expected_coverage/diff-gcc-original.out", "test/expected_coverage/diff-no-color.out", "test/expected_coverage/diff.out", "test/expected_coverage/gcc-text.out", "test/expected_coverage/sample_03_rb.html", "test/expected_coverage/sample_03_rb.rb", "test/expected_coverage/sample_04_rb.html", "editor-extensions/rcov.el", "setup.rb", "BLURB"]
  s.homepage = %q{http://github.com/relevance/rcov}
  s.rdoc_options = ["--title", "rcov code coverage tool"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Code coverage analysis tool for Ruby}
  s.test_files = ["test/functional_test.rb", "test/file_statistics_test.rb", "test/code_coverage_analyzer_test.rb", "test/call_site_analyzer_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
