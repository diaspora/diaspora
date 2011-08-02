require "spec_helper"
require "autotest/rails_rspec2"

describe Autotest::RailsRspec2 do

  let(:rails_rspec2_autotest) { Autotest::RailsRspec2.new }

  describe 'exceptions' do
    let(:exceptions_regexp) { rails_rspec2_autotest.exceptions }

    it "should match './log/test.log'" do
      exceptions_regexp.should match('./log/test.log')
    end

    it "should match 'log/test.log'" do
      exceptions_regexp.should match('log/test.log')
    end

    it "should not match './spec/models/user_spec.rb'" do
      exceptions_regexp.should_not match('./spec/models/user_spec.rb')
    end

    it "should not match 'spec/models/user_spec.rb'" do
      exceptions_regexp.should_not match('spec/models/user_spec.rb')
    end
  end

  describe 'mappings' do
    it 'runs model specs when support files change' do
      rails_rspec2_autotest.find_order = %w(spec/models/user_spec.rb spec/support/blueprints.rb)
      rails_rspec2_autotest.test_files_for('spec/support/blueprints.rb').should(
        include('spec/models/user_spec.rb'))
    end
  end

end
