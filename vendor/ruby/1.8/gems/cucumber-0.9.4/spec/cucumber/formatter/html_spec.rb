require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'cucumber/formatter/html'
require 'nokogiri'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module Formatter

    describe Html do
      extend SpecHelperDsl
      include SpecHelper

      matcher = defined?(Spec::Matchers) ? Spec::Matchers : RSpec::Matchers

      matcher.define :have_css_node do |css, regexp|
        match do |doc|
          nodes = doc.css(css)
          nodes.detect{ |node| node.text =~ regexp }
        end
      end
    
      before(:each) do
        @out = StringIO.new
        @formatter = Html.new(step_mother, @out, {})
        step_mother.visitor = @formatter
      end
    
      it "should not raise an error when visiting a blank feature name" do
        lambda { @formatter.feature_name("Feature", "") }.should_not raise_error
      end
      
      describe "given a single feature" do
        before(:each) do
          run_defined_feature
          @doc = Nokogiri.HTML(@out.string)
        end
        
        describe "basic feature" do
          define_feature <<-FEATURE
            Feature: Bananas
              In order to find my inner monkey
              As a human
              I must eat bananas
          FEATURE
                
          it "should output a main container div" do
            @out.string.should =~ /\<div class="cucumber"\>/
          end
        end
        
        describe "with a comment" do
          define_feature <<-FEATURE
            # Healthy
            Feature: Foo
          FEATURE
        
          it { @out.string.should =~ /^\<!DOCTYPE/ }
          it { @out.string.should =~ /\<\/html\>$/ }
          it { @doc.should have_css_node('.feature .comment', /Healthy/) }
        end
      
        describe "with a tag" do
          define_feature <<-FEATURE
            @foo
            Feature: can't have standalone tag :)
          FEATURE

          it { @doc.should have_css_node('.feature .tag', /foo/) }
        end
      
        describe "with a narrative" do
          define_feature <<-FEATURE
            Feature: Bananas
              In order to find my inner monkey
              As a human
              I must eat bananas
          FEATURE

          it { @doc.should have_css_node('.feature h2', /Bananas/) }
          it { @doc.should have_css_node('.feature .narrative', /must eat bananas/) }
        end
      
        describe "with a background" do
          define_feature <<-FEATURE
            Feature: Bananas
          
            Background:
              Given there are bananas
          FEATURE

          it { @doc.should have_css_node('.feature .background', /there are bananas/) }
        end
      
        describe "with a scenario" do
          define_feature <<-FEATURE
          Feature: Banana party

            Scenario: Monkey eats banana
              Given there are bananas
          FEATURE

          it { @doc.should have_css_node('.feature h3', /Monkey eats banana/) }
          it { @doc.should have_css_node('.feature .scenario .step', /there are bananas/) }
        end
      
        describe "with a scenario outline" do
          define_feature <<-FEATURE
          Feature: Fud Pyramid

            Scenario Outline: Monkey eats a balanced diet
              Given there are <Things>
          
              Examples: Fruit
               | Things  |
               | apples  |
               | bananas |
              Examples: Vegetables
               | Things   |
               | broccoli |
               | carrots  |
          FEATURE
        
          it { @doc.should have_css_node('.feature .scenario.outline h4', /Fruit/) }
          it { @doc.should have_css_node('.feature .scenario.outline h4', /Vegetables/) }
          it { @doc.css('.feature .scenario.outline h4').length.should == 2}
          it { @doc.should have_css_node('.feature .scenario.outline table', //) }
          it { @doc.should have_css_node('.feature .scenario.outline table td', /carrots/) }
        end
      
        describe "with a step with a py string" do
          define_feature <<-FEATURE
          Feature: Traveling circus

            Scenario: Monkey goes to town
              Given there is a monkey called:
               """
               foo
               """
          FEATURE
        
          it { @doc.should have_css_node('.feature .scenario .val', /foo/) }
        end

        describe "with a multiline step arg" do
          define_feature <<-FEATURE
          Feature: Traveling circus

            Scenario: Monkey goes to town
              Given there are monkeys:
               | name |
               | foo  |
               | bar  |
          FEATURE
        
          it { @doc.should have_css_node('.feature .scenario table td', /foo/) }
        end
      
        describe "with a table in the background and the scenario" do
          define_feature <<-FEATURE
          Feature: accountant monkey

            Background:
              Given table:
                | a | b |
                | c | d |
            Scenario:
              Given another table:
               | e | f |
               | g | h |
          FEATURE
        
          it { @doc.css('td').length.should == 8 }
        end
      
        describe "with a py string in the background and the scenario" do
          define_feature <<-FEATURE
          Feature: py strings

            Background:
              Given stuff:
                """
                foo
                """
            Scenario:
              Given more stuff:
                """
                bar
                """
          FEATURE

          it { @doc.css('.feature .background pre.val').length.should == 1 }
          it { @doc.css('.feature .scenario pre.val').length.should == 1 }
        end
      
        describe "with a step that fails in the scenario" do
          define_steps do
            Given(/boo/) { raise 'eek' }
          end
        
          define_feature(<<-FEATURE)
          Feature: Animal Cruelty

            Scenario: Monkey gets a fright
              Given boo
            FEATURE
      
          it { @doc.should have_css_node('.feature .scenario .step.failed', /eek/) }
        end
      
        describe "with a step that fails in the backgound" do
          define_steps do
            Given(/boo/) { raise 'eek' }
          end
        
          define_feature(<<-FEATURE)
          Feature: shouting
            Background:
              Given boo
            Scenario:
              Given yay
            FEATURE
        
          it { @doc.should have_css_node('.feature .background .step.failed', /eek/) }
          it { @doc.should_not have_css_node('.feature .scenario .step.failed', //) }
          it { @doc.should have_css_node('.feature .scenario .step.undefined', /yay/) }
        end

        describe "with a step that embeds a snapshot" do
          define_steps do
            Given(/snap/) { embed('snapshot.jpeg', 'image/jpeg') }
          end

          define_feature(<<-FEATURE)
          Feature: 
            Scenario:
              Given snap
            FEATURE

          it { @doc.css('.embed img').first.attributes['src'].to_s.should == "snapshot.jpeg" }
        end
        
        describe "with an undefined Given step then an undefined And step" do
          define_feature(<<-FEATURE)
          Feature: 
            Scenario:
              Given some undefined step
              And another undefined step
            FEATURE
            
          it { @doc.css('pre').map { |pre| /^(Given|And)/.match(pre.text)[1] }.should == ["Given", "Given"] }
        end
      
      end
    end
  end
end

