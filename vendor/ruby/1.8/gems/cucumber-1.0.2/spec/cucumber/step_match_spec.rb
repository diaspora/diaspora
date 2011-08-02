# encoding: utf-8
require 'spec_helper'
require 'cucumber/rb_support/rb_step_definition'
require 'cucumber/rb_support/rb_language'

module Cucumber
  describe StepMatch do
    WORD = Cucumber::RUBY_1_9 ? '[[:word:]]' : '\w'

    before do
      @rb_language = RbSupport::RbLanguage.new(nil)
    end

    def stepdef(regexp)
      RbSupport::RbStepDefinition.new(@rb_language, regexp, lambda{})
    end

    def step_match(regexp, name)
      stepdef = stepdef(regexp)
      StepMatch.new(stepdef, name, nil, stepdef.arguments_from(name))
    end

    it "should format one group when we use Unicode" do
      m = step_match(/I (#{WORD}+) ok/, "I æøåÆØÅæøåÆØÅæøåÆØÅæøåÆØÅ ok")
      m.format_args("<span>%s</span>").should == "I <span>æøåÆØÅæøåÆØÅæøåÆØÅæøåÆØÅ</span> ok"
    end

    it "should format several groups when we use Unicode" do
      m = step_match(/I (#{WORD}+) (#{WORD}+) (#{WORD}+) this (#{WORD}+)/, "I ate æøåÆØÅæøåÆØÅæøåÆØÅæøåÆØÅ egg this morning")
      m.format_args("<span>%s</span>").should == "I <span>ate</span> <span>æøåÆØÅæøåÆØÅæøåÆØÅæøåÆØÅ</span> <span>egg</span> this <span>morning</span>"
    end

    it "should deal with Unicode both inside and outside arguments" do
      "Jæ vø ålsker døtte løndet".should =~ /Jæ (.+) ålsker (.+) løndet/
      m = step_match(/Jæ (#{WORD}+) ålsker (#{WORD}+) løndet/, "Jæ vø ålsker døtte løndet")
      m.format_args("<span>%s</span>").should == "Jæ <span>vø</span> ålsker <span>døtte</span> løndet"
    end

    it "should format groups with format string" do
      m = step_match(/I (#{WORD}+) (\d+) (#{WORD}+) this (#{WORD}+)/, "I ate 1 egg this morning")
      m.format_args("<span>%s</span>").should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
    end

    it "should format groups with format string when there are dupes" do
      m = step_match(/I (#{WORD}+) (\d+) (#{WORD}+) this (#{WORD}+)/, "I bob 1 bo this bobs")
      m.format_args("<span>%s</span>").should == "I <span>bob</span> <span>1</span> <span>bo</span> this <span>bobs</span>"
    end

    it "should format groups with block" do
      m = step_match(/I (#{WORD}+) (\d+) (#{WORD}+) this (#{WORD}+)/, "I ate 1 egg this morning")
      m.format_args(&lambda{|m| "<span>#{m}</span>"}).should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
    end

    it "should format groups with proc object" do
      m = step_match(/I (#{WORD}+) (\d+) (#{WORD}+) this (#{WORD}+)/, "I ate 1 egg this morning")
      m.format_args(lambda{|m| "<span>#{m}</span>"}).should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
    end

    it "should format groups even when first group is optional and not matched" do
      m = step_match(/should( not)? be flashed '([^']*?)'$/, "I should be flashed 'Login failed.'")
      m.format_args("<span>%s</span>").should == "I should be flashed '<span>Login failed.</span>'"
    end

    it "should format embedded groups" do
      m = step_match(/running( (\d+) times)? (\d+) meters/, "running 5 times 10 meters")
      m.format_args("<span>%s</span>").should == "running<span> 5 times</span> <span>10</span> meters"
    end
  end
end