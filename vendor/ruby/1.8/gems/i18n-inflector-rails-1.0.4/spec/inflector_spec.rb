require 'spec_helper'

class ApplicationController < ActionController::Base;       end
class InflectedTranslateController < ApplicationController; end
class InflectedStrictController    < ApplicationController; end

describe I18n.inflector.options.class do

  context "instance I18n.inflector.options" do

    it "should contain verify_methods switch" do
      I18n.inflector.options.should respond_to :verify_methods
    end

    it "should have default value set to false" do
      I18n.inflector.options.verify_methods.should == false
    end

  end

end

describe ApplicationController do

  before do

    I18n.locale = :xx
    I18n.backend.store_translations(:xx, :i18n => { :inflections => {
                                                     :gender => {
                                                       :m => 'male',
                                                       :f => 'female',
                                                       :n => 'neuter',
                                                       :s => 'strange',
                                                       :masculine  => '@m',
                                                       :feminine   => '@f',
                                                       :neuter     => '@n',
                                                       :neutral    => '@neuter',
                                                       :default    => 'neutral' },
                                                      :time => {
                                                        :present  => 'present',
                                                        :past     => 'past',
                                                        :future   => 'future'},
                                                      :@gender => {
                                                        :m => 'male',
                                                        :f => 'female',
                                                        :d => 'dude',
                                                        :x => 'tester',
                                                        :n => 'neuter',
                                                        :default => 'n'},
                                                      :person => {
                                                        :i   => 'I',
                                                        :you => 'You',
                                                        :it  => 'It'},
                                                      :@person => {
                                                        :i   => 'I',
                                                        :you => 'You',
                                                        :it  => 'It'},
                                       }   })

   I18n.backend.store_translations(:ns, 'welcome'         => 'Dear @{f:Lady|m:Sir|n:You|All}!')
   I18n.backend.store_translations(:xx, 'welcome'         => 'Dear @{f:Lady|m:Sir|n:You|All}!')
   I18n.backend.store_translations(:xx, 'welcome_strict'  => 'Dear @gender{f:Lady|m:Sir|d:Dude|n:You|All}!')
   I18n.backend.store_translations(:xx, 'to_be'           => 'Oh @{i:I am|you:You are|it:It is}')
   I18n.backend.store_translations(:xx, 'to_be_strict'    => 'Oh @person{i:me|you:You are|it:It is}')
   I18n.backend.store_translations(:xx, 'hitime'          => '@{present,past,future:~}!')

  end

  describe ".inflection_method" do

    before do
      class AnotherController < InflectedTranslateController; end
    end

    it "should be albe to assign a mehtod to the inflection kind" do
      lambda{AnotherController.inflection_method(:users_gender => :gender)}.should_not raise_error
    end

    it "should be albe to assign a mehtod to the strict inflection kind" do
      lambda{AnotherController.inflection_method(:users_gender => :@gender)}.should_not raise_error
    end

    it "should be albe to accept single Symbol argument" do
      lambda{AnotherController.inflection_method(:time)}.should_not raise_error
      lambda{AnotherController.inflection_method(:@time)}.should_not raise_error
    end

    it "should be albe to accept single String argument" do
      lambda{AnotherController.inflection_method('time')}.should_not raise_error
      lambda{AnotherController.inflection_method('@time')}.should_not raise_error
    end

    it "should be albe to accept Array<Symbol> argument" do
      lambda{AnotherController.inflection_method([:time])}.should_not raise_error
      lambda{AnotherController.inflection_method([:@time])}.should_not raise_error
    end

    it "should raise an error when method name is wrong" do
      lambda{AnotherController.inflection_method}.should                  raise_error
      lambda{AnotherController.inflection_method(nil => :blabla)}.should  raise_error
      lambda{AnotherController.inflection_method(:blabla => nil)}.should  raise_error
      lambda{AnotherController.inflection_method(nil => :@blabla)}.should raise_error
      lambda{AnotherController.inflection_method(:@blabla => nil)}.should raise_error
      lambda{AnotherController.inflection_method(:"@")}.should            raise_error
      lambda{AnotherController.inflection_method({''=>''})}.should        raise_error
      lambda{AnotherController.inflection_method(nil => nil)}.should      raise_error
      lambda{AnotherController.inflection_method(nil)}.should             raise_error
      lambda{AnotherController.inflection_method([nil])}.should           raise_error
      lambda{AnotherController.inflection_method([''])}.should            raise_error
      lambda{AnotherController.inflection_method([])}.should              raise_error
      lambda{AnotherController.inflection_method({})}.should              raise_error
    end

  end

  describe ".no_inflection_method" do

    before do
      class AnotherController < InflectedTranslateController; end
    end

    it "should be albe to split a mehtod of the inflection kind" do
      lambda{AnotherController.no_inflection_method(:users_gender)}.should_not raise_error
    end

    it "should be albe to accept single Symbol argument" do
      lambda{AnotherController.no_inflection_method(:time)}.should_not raise_error
      lambda{AnotherController.no_inflection_method(:@time)}.should_not raise_error
    end

    it "should be albe to accept single String argument" do
      lambda{AnotherController.no_inflection_method('time')}.should_not raise_error
      lambda{AnotherController.no_inflection_method('@time')}.should_not raise_error
    end

    it "should be albe to accept Array<Symbol> argument" do
      lambda{AnotherController.no_inflection_method([:time])}.should_not raise_error
      lambda{AnotherController.no_inflection_method([:@time])}.should_not raise_error
    end

    it "should raise an error when method name is wrong" do
      lambda{AnotherController.no_inflection_method}.should         raise_error
      lambda{AnotherController.no_inflection_method(nil)}.should    raise_error
      lambda{AnotherController.no_inflection_method([nil])}.should  raise_error
      lambda{AnotherController.no_inflection_method(:"@")}.should   raise_error
      lambda{AnotherController.no_inflection_method([''])}.should   raise_error
      lambda{AnotherController.no_inflection_method([])}.should     raise_error
      lambda{AnotherController.no_inflection_method({})}.should     raise_error
    end

  end

  describe ".no_inflection_kind" do

    before do
      class AnotherController < InflectedTranslateController; end
    end

    it "should be albe to spit a mehtod of the inflection kind" do
      lambda{AnotherController.no_inflection_kind(:gender)}.should_not raise_error
      lambda{AnotherController.no_inflection_kind(:@gender)}.should_not raise_error
    end

    it "should be albe to accept single Symbol argument" do
      lambda{AnotherController.no_inflection_kind(:time)}.should_not raise_error
      lambda{AnotherController.no_inflection_kind(:@time)}.should_not raise_error
    end

    it "should be albe to accept single String argument" do
      lambda{AnotherController.no_inflection_kind('time')}.should_not raise_error
      lambda{AnotherController.no_inflection_kind('@time')}.should_not raise_error
    end

    it "should be albe to accept Array<Symbol> argument" do
      lambda{AnotherController.no_inflection_kind([:time])}.should_not raise_error
      lambda{AnotherController.no_inflection_kind([:@time])}.should_not raise_error
    end

    it "should raise an error when method name is wrong" do
      lambda{AnotherController.no_inflection_kind}.should        raise_error
      lambda{AnotherController.no_inflection_kind(nil)}.should   raise_error
      lambda{AnotherController.no_inflection_kind(:"@")}.should  raise_error
      lambda{AnotherController.no_inflection_kind([nil])}.should raise_error
      lambda{AnotherController.no_inflection_kind([''])}.should  raise_error
      lambda{AnotherController.no_inflection_kind([])}.should    raise_error
      lambda{AnotherController.no_inflection_kind({})}.should    raise_error
    end

  end

  describe ".i18n_inflector_kinds" do

    before do
      InflectedTranslateController.inflection_method(:users_gender => :gender)
      InflectedTranslateController.inflection_method(:time) 
      @expected_hash =  { :gender => :users_gender, :time   => :time }
    end

    it "should be callable" do
      lambda{InflectedTranslateController.i18n_inflector_kinds}.should_not raise_error
    end

    it "should be able to read methods assigned to inflection kinds" do
      InflectedTranslateController.i18n_inflector_kinds.should ==  @expected_hash
    end

  end

  describe "controller instance methods" do

    before do

      class InflectedTranslateController
        def trn(*args); t(*args)          end
        def t_male; t('welcome')          end
        def users_gender; :m              end
        def time
          kind, locale = yield
          kind == :time ? :past : nil
        end
      end

      class InflectedStrictController
        inflection_method :@gender

        def gender; :m end
        def trn(*args);  translate(*args) end
      end

      class InflectedStrictOverrideController < InflectedTranslateController
        inflection_method :users_dude     => :@gender
        inflection_method :users_female   => :gender
        inflection_method :person_i       => :person

        no_inflection_method_for :@person

        def users_female; :f end
        def users_dude;   :d end
        def person_i;     :i end
      end

      class NomethodController < InflectedTranslateController
        inflection_method :nonexistent => :gender
      end

      class MethodDisabledController < InflectedTranslateController
        no_inflection_method :users_gender
      end

      @controller             = InflectedTranslateController.new
      @strict_controller      = InflectedStrictController.new
      @strict_over_controller = InflectedStrictOverrideController.new
      @disabled_controller    = MethodDisabledController.new
      @nomethod_controller    = NomethodController.new

    end

    describe "#i18n_inflector_kinds" do

      before do
        @expected_hash = {:gender => :users_gender, :time => :time }
      end

      it "should be able to read methods assigned to inflection kinds" do
        @controller.i18n_inflector_kinds.should == @expected_hash
      end

    end

    describe "#translate" do

      it "should translate using inflection patterns and pick up the right value" do
        @controller.trn('welcome').should == 'Dear Sir!'
        @controller.trn('welcome_strict').should == 'Dear Sir!'
        @strict_controller.trn('welcome_strict').should == 'Dear Sir!'
      end

      it "should make use of a block passed to inflection method" do
        @controller.trn('hitime').should == 'past!'
      end

      it "should make use of inherited inflection method assignments" do
        @strict_over_controller.trn('hitime').should == 'past!'
      end

      it "should make use of overriden inflection method assignments" do
        @strict_over_controller.trn('welcome').should == 'Dear Lady!'
      end

      it "should prioritize strict kinds when both inflection options are passed" do
        @strict_over_controller.trn('welcome_strict').should == 'Dear Dude!'
        @strict_over_controller.trn('welcome').should == 'Dear Lady!'
      end

      it "should use regular kind option when strict kind option is missing" do
        @strict_over_controller.trn('to_be').should == 'Oh I am'
        @strict_over_controller.trn('to_be_strict').should == 'Oh me'
      end

      it "should make use of disabled inflection method assignments" do
        @disabled_controller.trn('welcome').should == 'Dear You!'
      end

      it "should raise exception when method does not exists" do
        lambda{@nomethod_controller.translated_male}.should raise_error(NameError)
      end

      it "should not raise when method does not exists and verify_methods is enabled" do
        lambda{@nomethod_controller.trn('welcome', :inflector_verify_methods => true)}.should_not raise_error(NameError)
        I18n.inflector.options.verify_methods = true
        lambda{@nomethod_controller.trn('welcome')}.should_not raise_error(NameError)
      end

      it "should translate with the :inflector_lazy_methods switch turned off" do
        @strict_over_controller.trn('welcome', :inflector_lazy_methods => false).should == 'Dear Lady!'
      end

      it "should omit pattern interpolation when locale is not inflected" do
        @strict_over_controller.trn('welcome', :locale => :ns).should == 'Dear !'
      end

    end

    describe "#t" do

      it "should call translate" do
        @controller.t_male.should == 'Dear Sir!'
      end

    end

  end

end
