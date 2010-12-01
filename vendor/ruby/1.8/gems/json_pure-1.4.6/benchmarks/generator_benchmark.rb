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
when 'rails'
  require 'active_support'
when 'yajl'
  require 'yajl'
  require 'yajl/json_gem'
  require 'stringio'
end

module JSON
  def self.[](*) end
end

module GeneratorBenchmarkCommon
  include JSON

  def setup
    a = [ nil, false, true, "fÖßÄr", [ "n€st€d", true ], { "fooß" => "bär", "quux" => true } ]
    puts a.to_json if a.respond_to?(:to_json)
    @big = a * 100
  end

  def generic_reset_method
    @result and @result.size > 2 + 6 * @big.size or raise @result.to_s
  end
end

module JSONGeneratorCommon
  include GeneratorBenchmarkCommon

  def benchmark_generator_fast
    @result = JSON.fast_generate(@big)
  end

  alias reset_benchmark_generator_fast generic_reset_method

  def benchmark_generator_safe
    @result = JSON.generate(@big)
  end

  alias reset_benchmark_generator_safe generic_reset_method

  def benchmark_generator_pretty
    @result = JSON.pretty_generate(@big)
  end

  alias reset_benchmark_generator_pretty generic_reset_method

  def benchmark_generator_ascii
    @result = JSON.generate(@big, :ascii_only => true)
  end

  alias reset_benchmark_generator_ascii generic_reset_method
end

class GeneratorBenchmarkExt < Bullshit::RepeatCase
  include JSONGeneratorCommon

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
end

class GeneratorBenchmarkPure < Bullshit::RepeatCase
  include JSONGeneratorCommon

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
end

class GeneratorBenchmarkRails < Bullshit::RepeatCase
  include GeneratorBenchmarkCommon

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

  def benchmark_generator
    @result = @big.to_json
  end

  alias reset_benchmark_generator generic_reset_method
end

class GeneratorBenchmarkYajl < Bullshit::RepeatCase
  include GeneratorBenchmarkCommon

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

  def benchmark_generator
    output = StringIO.new
    Yajl::Encoder.new.encode(@big, output)
    @result = output.string
  end

  def benchmark_generator_gem_api
    @result = @big.to_json
  end

  def reset_benchmark_generator
    generic_reset_method
  end
end

if $0 == __FILE__
  Bullshit::Case.autorun false

  case ARGV.first
  when 'ext'
    GeneratorBenchmarkExt.run
  when 'pure'
    GeneratorBenchmarkPure.run
  when 'rails'
    GeneratorBenchmarkRails.run
  when 'yajl'
    GeneratorBenchmarkYajl.run
  else
    system "#{RAKE_PATH} clean"
    system "#{RUBY_PATH} #$0 rails"
    system "#{RUBY_PATH} #$0 pure"
    system "#{RAKE_PATH} compile_ext"
    system "#{RUBY_PATH} #$0 ext"
    system "#{RUBY_PATH} #$0 yajl"
    Bullshit.compare do
      output_filename File.join(File.dirname(__FILE__), 'data', 'GeneratorBenchmarkComparison.log')

      benchmark GeneratorBenchmarkExt,    :generator_fast,    :load => yes
      benchmark GeneratorBenchmarkExt,    :generator_safe,    :load => yes
      benchmark GeneratorBenchmarkExt,    :generator_pretty,  :load => yes
      benchmark GeneratorBenchmarkExt,    :generator_ascii,    :load => yes
      benchmark GeneratorBenchmarkPure,   :generator_fast,    :load => yes
      benchmark GeneratorBenchmarkPure,   :generator_safe,    :load => yes
      benchmark GeneratorBenchmarkPure,   :generator_pretty,  :load => yes
      benchmark GeneratorBenchmarkPure,   :generator_ascii,   :load => yes
      benchmark GeneratorBenchmarkRails,  :generator,         :load => yes
      benchmark GeneratorBenchmarkYajl,   :generator,         :load => yes
      benchmark GeneratorBenchmarkYajl,   :generator_gem_api, :load => yes
    end
  end
end

