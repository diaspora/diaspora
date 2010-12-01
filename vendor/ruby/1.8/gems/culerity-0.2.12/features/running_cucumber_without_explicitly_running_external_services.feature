Feature: Running cucumber without explicitly running external services
  In order to reduce learning cost of using culerity
  As a rails developer
  I want the headless browser and rails processes to launch and shutdown automatically

  Background:
    Given a Rails app
      And I run executable "script/generate" with arguments "cucumber --rspec --webrat"
      And I delete file "features/step_definitions/web_steps.rb"
      And I delete file "features/support/env.rb"
      And culerity is installed as a plugin
      And I invoke task "rake db:migrate"
    When I run executable "script/generate" with arguments "culerity"
      And I setup load path to local code
      And I setup the culerity javascript helpers
      And I add the JRUBY_INVOCATION check to "features/support/env.rb"
      And I add an rvm_verbose_flag=0-wielding .rvmrc to the home folder  
  
  Scenario: Successfully run scenarios without requiring celerity or rails processes running
    When I add a feature file to test Rails index.html default file
      And I run executable "cucumber" with arguments "features/"
    Then file "tmp/culerity_rails_server.pid" is not created
      And I should see "1 scenario"
      And I should see "5 steps (5 passed)"
      And I should see "WARNING: Speed up execution by running 'rake culerity:rails:start'"
