require File.dirname(__FILE__) + '/ragel_task'
BYPASS_NATIVE_IMPL = true
require 'gherkin/i18n'

CLEAN.include [
  'pkg', 'tmp',
  '**/*.{o,bundle,jar,so,obj,pdb,lib,def,exp,log,rbc}', 'ext',
  'java/target',
  'ragel/i18n/*.rl',
  'lib/gherkin/rb_lexer/*.rb',
  'lib/*.dll',
  'ext/**/*.c',
  'java/src/main/java/gherkin/lexer/i18n/*.java',
  'java/src/main/resources/gherkin/*.properties',
  'js/lib/gherkin/lexer/*.js',
  'doc'
]

desc "Compile the Java extensions"
task :jar => 'lib/gherkin.jar'

file 'lib/gherkin.jar' => Dir['java/src/main/java/**/*.java'] do
  sh("mvn -f java/pom.xml package")
end

desc "Build Javascript lexers"
task :js

rl_langs = ENV['RL_LANGS'] ? ENV['RL_LANGS'].split(',') : []
langs = Gherkin::I18n.all.select { |lang| rl_langs.empty? || rl_langs.include?(lang.iso_code) }

# http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=6457127
file 'lib/gherkin.jar' => "java/src/main/resources/gherkin/I18nKeywords_in.properties"
file "java/src/main/resources/gherkin/I18nKeywords_in.properties" => "java/src/main/resources/gherkin/I18nKeywords_id.properties" do
  cp "java/src/main/resources/gherkin/I18nKeywords_id.properties", "java/src/main/resources/gherkin/I18nKeywords_in.properties"
end

# http://forums.sun.com/thread.jspa?threadID=5335461
file 'lib/gherkin.jar' => "java/src/main/resources/gherkin/I18nKeywords_iw.properties"
file "java/src/main/resources/gherkin/I18nKeywords_iw.properties" => "java/src/main/resources/gherkin/I18nKeywords_he.properties" do
  cp "java/src/main/resources/gherkin/I18nKeywords_he.properties", "java/src/main/resources/gherkin/I18nKeywords_iw.properties"
end

langs.each do |i18n|
  java = RagelTask.new('java', i18n)
  rb   = RagelTask.new('rb', i18n)
  js   = RagelTask.new('js', i18n)

  lang_country = i18n.iso_code.split(/-/)
  suffix = lang_country.length == 1 ? lang_country[0] : "#{lang_country[0]}_#{lang_country[1].upcase}"
  java_properties = "java/src/main/resources/gherkin/I18nKeywords_#{suffix}.properties"
  file java_properties => 'lib/gherkin/i18n.yml' do
    File.open(java_properties, 'wb') do |io|
      io.puts("# Generated file. Do not edit.")
      (Gherkin::I18n::KEYWORD_KEYS + %w{name native}).each do |key|
        value = Gherkin::I18n.unicode_escape(i18n.keywords(key).join("|"))
        io.puts("#{key}:#{value}")
      end
    end
  end
  file 'lib/gherkin.jar' => [java.target, rb.target, java_properties]

  begin
  if !defined?(JRUBY_VERSION)
    require 'rake/extensiontask'

    c = RagelTask.new('c', i18n)

    extconf = "ext/gherkin_lexer_#{i18n.underscored_iso_code}/extconf.rb"
    file extconf do
      FileUtils.mkdir(File.dirname(extconf)) unless File.directory?(File.dirname(extconf))
      File.open(extconf, "w") do |io|
        io.write(<<-EOF)
require 'mkmf'
CONFIG['warnflags'].gsub!(/-Wshorten-64-to-32/, '') if CONFIG['warnflags']
$CFLAGS << ' -O0 -Wall' if CONFIG['CC'] =~ /gcc/
dir_config("gherkin_lexer_#{i18n.underscored_iso_code}")
have_library("c", "main")
create_makefile("gherkin_lexer_#{i18n.underscored_iso_code}")
EOF
      end
    end

    Rake::ExtensionTask.new("gherkin_lexer_#{i18n.underscored_iso_code}") do |ext|
      if ENV['RUBY_CC_VERSION']
        ext.cross_compile = true
        ext.cross_platform = 'x86-mingw32'
      end
    end

    # The way tasks are defined with compile:xxx (but without namespace) in rake-compiler forces us
    # to use these hacks for setting up dependencies. Ugly!
    Rake::Task["compile:gherkin_lexer_#{i18n.underscored_iso_code}"].prerequisites.unshift(extconf)
    Rake::Task["compile:gherkin_lexer_#{i18n.underscored_iso_code}"].prerequisites.unshift(c.target)
    Rake::Task["compile:gherkin_lexer_#{i18n.underscored_iso_code}"].prerequisites.unshift(rb.target)
    Rake::Task["compile:gherkin_lexer_#{i18n.underscored_iso_code}"].prerequisites.unshift(js.target) if ENV['GHERKIN_JS']

    Rake::Task["compile"].prerequisites.unshift(extconf)
    Rake::Task["compile"].prerequisites.unshift(c.target)
    Rake::Task["compile"].prerequisites.unshift(rb.target)
    Rake::Task["compile"].prerequisites.unshift(js.target) if ENV['GHERKIN_JS']
    
    Rake::Task["js"].prerequisites.unshift(js.target) if ENV['GHERKIN_JS']
  end
  rescue LoadError
    unless defined?($c_warned)
      warn "WARNING: Rake::ExtensionTask not installed. Skipping C compilation." 
      $c_warned = true
      task :compile # no-op
    end
  end
end
