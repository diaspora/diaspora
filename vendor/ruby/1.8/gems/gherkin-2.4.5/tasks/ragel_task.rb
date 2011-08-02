require 'yaml'
require 'erb'

class RagelTask
  begin
    # Support Rake >= 0.9.0
    require 'rake/dsl_definition'
    include Rake::DSL
  rescue LoadError
  end

  RL_OUTPUT_DIR = File.dirname(__FILE__) + "/../ragel/i18n"

  def initialize(lang, i18n)
    @lang     = lang
    @i18n     = i18n
    define_tasks
  end

  def define_tasks
    file target => [lang_ragel, common_ragel] do
      mkdir_p(File.dirname(target)) unless File.directory?(File.dirname(target))
      sh "ragel #{flags} #{lang_ragel} -o #{target}"
      if(@lang == 'js')
        # Ragel chokes if we put the escaped triple quotes in .rl, so we'll do the replace with sed after the fact. Lots of backslashes!!
        sh %{sed -i '' 's/ESCAPED_TRIPLE_QUOTE/\\\\\\\\\\\\"\\\\\\\\\\\\"\\\\\\\\\\\\"/' #{target}}
      end
    end

    file lang_ragel => lang_erb do
      write(ERB.new(IO.read(lang_erb)).result(binding), lang_ragel)
    end

    file common_ragel => common_erb  do
      write(ERB.new(IO.read(common_erb)).result(binding), common_ragel)
    end
  end

  def target
    {
      'c'    => "ext/gherkin_lexer_#{@i18n.underscored_iso_code}/gherkin_lexer_#{@i18n.underscored_iso_code}.c",
      'java' => "java/src/main/java/gherkin/lexer/i18n/#{@i18n.underscored_iso_code.upcase}.java",
      'rb'   => "lib/gherkin/rb_lexer/#{@i18n.underscored_iso_code}.rb",
      'js'   => "js/lib/gherkin/lexer/#{@i18n.underscored_iso_code}.js"
    }[@lang]
  end

  def common_ragel
    RL_OUTPUT_DIR + "/lexer_common.#{@i18n.underscored_iso_code}.rl"
  end

  def common_erb
    File.dirname(__FILE__) + '/../ragel/lexer_common.rl.erb'
  end

  def lang_ragel
    RL_OUTPUT_DIR + "/#{@i18n.underscored_iso_code}.#{@lang}.rl"
  end

  def lang_erb
    File.dirname(__FILE__) + "/../ragel/lexer.#{@lang}.rl.erb"
  end

  def flags
    {
      'c'      => '-C',
      'java'   => '-J',
      'rb'     => '-R',
      'js'     => '-E'
    }[@lang]
  end

  def write(content, filename)
    mkdir_p(File.dirname(filename)) unless File.directory?(File.dirname(filename))
    File.open(filename, "wb") do |file|
      file.write(content)
    end
  end

  def ragel_list(keywords)
    "(#{keywords.map{|keyword| %{"#{keyword}"}}.join(' | ')})"
  end
end
