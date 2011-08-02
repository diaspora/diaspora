#!/usr/bin/env ruby
# CODING: UTF-8

require 'rbconfig'
RUBY_PATH=File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
RAKE_PATH=File.join(Config::CONFIG['bindir'], 'rake')
require 'bullshit'
case ARGV.first
when 'ext'
  require 'json/ext'
when 'pure'
  require 'json/pure'
when 'yaml'
  require 'yaml'
  require 'json/pure'
when 'rails'
  require 'active_support'
  require 'json/pure'
when 'yajl'
  require 'yajl'
  require 'json/pure'
else
  require 'json/pure'
end

module Parser2BenchmarkCommon
  include JSON

  def setup
    @big = @json = File.read(File.join(File.dirname(__FILE__), 'ohai.json'))
  end

  def generic_reset_method
    @result == @big or raise "not equal"
  end
end

class Parser2BenchmarkExt < Bullshit::RepeatCase
  include Parser2BenchmarkCommon

  warmup      yes
  iterations  2000

  truncate_data do
    enabled false
    alpha_level 0.05
    window_size 50
    slope_angle 0.1
  end

  autocorrelation do
    alpha_level 0.05
    max_lags    50
    file        yes
  end

  output_dir File.join(File.dirname(__FILE__), 'data')
  output_filename benchmark_name + '.log'
  data_file yes
  histogram yes

  def benchmark_parser
    @result = JSON.parse(@json)
  end

  alias reset_parser generic_reset_method

  def benchmark_parser_symbolic
    @result = JSON.parse(@json, :symbolize_names => true)
  end

  alias reset_parser_symbolc generic_reset_method
end

class Parser2BenchmarkPure < Bullshit::RepeatCase
  include Parser2BenchmarkCommon

  warmup      yes
  iterations  400

  truncate_data do
    enabled false
    alpha_level 0.05
    window_size 50
    slope_angle 0.1
  end

  autocorrelation do
    alpha_level 0.05
    max_lags    50
    file        yes
  end

  output_dir File.join(File.dirname(__FILE__), 'data')
  output_filename benchmark_name + '.log'
  data_file yes
  histogram yes

  def benchmark_parser
    @result = JSON.parse(@json)
  end

  alias reset_parser generic_reset_method

  def benchmark_parser_symbolic
    @result = JSON.parse(@json, :symbolize_names => true)
  end

  alias reset_parser_symbolc generic_reset_method
end

class Parser2BenchmarkYAML < Bullshit::RepeatCase
  warmup      yes
  iterations  400

  truncate_data do
    enabled false
    alpha_level 0.05
    window_size 50
    slope_angle 0.1
  end

  autocorrelation do
    alpha_level 0.05
    max_lags    50
    file        yes
  end

  output_dir File.join(File.dirname(__FILE__), 'data')
  output_filename benchmark_name + '.log'
  data_file yes
  histogram yes

  def setup
    @big = @json = File.read(File.join(File.dirname(__FILE__), 'ohai.json'))
  end

  def benchmark_parser
    @result = YAML.load(@json)
  end

  def generic_reset_method
    @result == @big or raise "not equal"
  end
end

class Parser2BenchmarkRails < Bullshit::RepeatCase
  warmup      yes
  iterations  400

  truncate_data do
    alpha_level 0.05
    window_size 50
    slope_angle 0.1
  end

  autocorrelation do
    alpha_level 0.05
    max_lags    50
    file        yes
  end

  output_dir File.join(File.dirname(__FILE__), 'data')
  output_filename benchmark_name + '.log'
  data_file yes
  histogram yes

  def setup
    a = [ nil, false, true, "fÖß\nÄr", [ "n€st€d", true ], { "fooß" => "bär", "qu\r\nux" => true } ]
    @big = a * 100
    @json = JSON.generate(@big)
  end

  def benchmark_parser
    @result = ActiveSupport::JSON.decode(@json)
  end

  def generic_reset_method
    @result == @big or raise "not equal"
  end
end

class Parser2BenchmarkYajl < Bullshit::RepeatCase
  warmup      yes
  iterations  2000

  truncate_data do
    alpha_level 0.05
    window_size 50
    slope_angle 0.1
  end

  autocorrelation do
    alpha_level 0.05
    max_lags    50
    file        yes
  end

  output_dir File.join(File.dirname(__FILE__), 'data')
  output_filename benchmark_name + '.log'
  data_file yes
  histogram yes

  def setup
    @big = @json = File.read(File.join(File.dirname(__FILE__), 'ohai.json'))
  end

  def benchmark_parser
    @result = Yajl::Parser.new.parse(@json)
  end

  def generic_reset_method
    @result == @big or raise "not equal"
  end
end

if $0 == __FILE__
  Bullshit::Case.autorun false

  case ARGV.first
  when 'ext'
    Parser2BenchmarkExt.run
  when 'pure'
    Parser2BenchmarkPure.run
  when 'yaml'
    Parser2BenchmarkYAML.run
  when 'rails'
    Parser2BenchmarkRails.run
  when 'yajl'
    Parser2BenchmarkYajl.run
  else
    system "#{RAKE_PATH} clean"
    system "#{RUBY_PATH} #$0 yaml"
    system "#{RUBY_PATH} #$0 rails"
    system "#{RUBY_PATH} #$0 pure"
    system "#{RAKE_PATH} compile_ext"
    system "#{RUBY_PATH} #$0 ext"
    system "#{RUBY_PATH} #$0 yajl"
    Bullshit.compare do
      output_filename File.join(File.dirname(__FILE__), 'data', 'Parser2BenchmarkComparison.log')

      benchmark Parser2BenchmarkExt,   :parser, :load => yes
      benchmark Parser2BenchmarkExt,   :parser_symbolic, :load => yes
      benchmark Parser2BenchmarkPure,  :parser, :load => yes
      benchmark Parser2BenchmarkPure,  :parser_symbolic, :load => yes
      benchmark Parser2BenchmarkYAML,  :parser, :load => yes
      benchmark Parser2BenchmarkRails, :parser, :load => yes
      benchmark Parser2BenchmarkYajl,  :parser, :load => yes
    end
  end
end
