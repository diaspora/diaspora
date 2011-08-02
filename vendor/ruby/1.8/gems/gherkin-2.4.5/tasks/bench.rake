%w{/../lib /bench}.each do |l| 
  $LOAD_PATH << File.expand_path(File.dirname(__FILE__) + l)
end

require 'benchmark'

GENERATED_FEATURES = File.expand_path(File.dirname(__FILE__) + "/bench/generated")

class RandomFeatureGenerator
  def initialize(number)
    require 'faker'
    require 'feature_builder'
    
    @number = number
  end
  
  def generate
    @number.times do
      name = catch_phrase
      feature = FeatureBuilder.new(name) do |f|
        num_scenarios = rand_in(1..10)
        num_scenarios.times do
          f.scenario(bs) do |steps|
            num_steps = rand_in(3..10)
            num_steps.times do
              steps.step(sentence, self)
            end
          end
        end
      end      
      write feature.to_s, name
    end    
  end
  
  def write(content, name)
    File.open(GENERATED_FEATURES + "/#{name.downcase.gsub(/[\s\-\/]/, '_')}.feature", "w+") do |file|
      file << content
    end
  end
  
  def rand_in(range)
    ary = range.to_a
    ary[rand(ary.length - 1)]
  end
  
  def catch_phrase
    Faker::Company.catch_phrase
  end
  
  def bs
    Faker::Company.bs.capitalize
  end
  
  def sentence
    Faker::Lorem.sentence
  end

  def table_cell
    Faker::Lorem.words(rand(2)+1).join(" ")
  end
end

class Benchmarker
  def initialize
    @features = Dir[GENERATED_FEATURES + "/**/*feature"]
  end
  
  def report(lexer)
    Benchmark.bm do |x|
      x.report("#{lexer}:") { send :"run_#{lexer}" }
    end
  end
  
  def report_all 
    Benchmark.bmbm do |x|
      x.report("native_gherkin:") { run_native_gherkin }
      x.report("native_gherkin_no_parser:") { run_native_gherkin_no_parser }
      x.report("rb_gherkin:") { run_rb_gherkin }
      x.report("cucumber:") { run_cucumber }
      x.report("tt:") { run_tt }
    end
  end
  
  def run_cucumber
    require 'cucumber'
    require 'logger'
    step_mother = Cucumber::StepMother.new
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    step_mother.log = logger
    step_mother.load_plain_text_features(@features)
  end
  
  def run_tt
    require 'cucumber'
    # Using Cucumber's Treetop lexer, but never calling #build to build the AST
    lexer = Cucumber::Parser::NaturalLanguage.new(nil, 'en').parser
    @features.each do |file|
      source = IO.read(file)
      parse_tree = lexer.parse(source)
      if parse_tree.nil?
        raise Cucumber::Parser::SyntaxError.new(lexer, file, 0)
      end
    end
  end

  def run_rb_gherkin    
    require 'gherkin'
    require 'null_formatter'
    parser = Gherkin::Parser::Parser.new(NullFormatter.new, true, "root", true)
    @features.each do |feature|
      parser.parse(File.read(feature), feature, 0)
    end
  end

  def run_native_gherkin
    require 'gherkin'
    require 'null_listener'
    parser = Gherkin::Parser::Parser.new(NullFormatter.new, true, "root", false)
    @features.each do |feature|
      parser.parse(File.read(feature), feature, 0)
    end
  end

  def run_native_gherkin_no_parser
    require 'gherkin'
    require 'gherkin/lexer/i18n_lexer'
    require 'null_listener'
    lexer = Gherkin::Lexer::I18nLexer.new(NullListener.new, false)
    @features.each do |feature|
      lexer.scan(File.read(feature), feature, 0)
    end
  end
end

desc "Generate 500 random features and benchmark Cucumber, Treetop and Gherkin with them"
task :bench => ["bench:clean", "bench:gen"] do
  benchmarker = Benchmarker.new
  benchmarker.report_all
end

namespace :bench do
  desc "Generate [number] features with random content, or 500 features if number is not provided"
  task :gen, :number do |t, args|
    args.with_defaults(:number => 500)
    generator = RandomFeatureGenerator.new(args.number.to_i)
    generator.generate    
  end

  desc "Benchmark Cucumber AST building from the features in tasks/bench/generated"
  task :cucumber do
    benchmarker = Benchmarker.new
    benchmarker.report("cucumber")
  end
  
  desc "Benchmark the Treetop parser with the features in tasks/bench/generated"
  task :tt do
    benchmarker = Benchmarker.new
    benchmarker.report("tt")
  end

  desc "Benchmark the Ruby Gherkin lexer+parser with the features in tasks/bench/generated"
  task :rb_gherkin do
    benchmarker = Benchmarker.new
    benchmarker.report("rb_gherkin")
  end

  desc "Benchmark the ntive Gherkin lexer+parser with the features in tasks/bench/generated"
  task :native_gherkin do
    benchmarker = Benchmarker.new
    benchmarker.report("native_gherkin")
  end

  desc "Benchmark the native Gherkin lexer (no parser) with the features in tasks/bench/generated"
  task :native_gherkin_no_parser do
    benchmarker = Benchmarker.new
    benchmarker.report("native_gherkin_no_parser")
  end

  desc "Remove all generated features in tasks/bench/generated"
  task :clean do
    rm_f FileList[GENERATED_FEATURES + "/**/*feature"]
  end
end
