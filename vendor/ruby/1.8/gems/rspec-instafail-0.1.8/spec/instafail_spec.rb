describe 'RSpec::Instafail' do
  it "works correctly with RSpec 1.x" do
    output = `cd spec/rspec_1 && bundle exec spec a_test.rb --format RSpec::Instafail`
    expected_output = <<EXP
  1\\) x a
     expected: 2,
     got: 1 \\(using ==\\)
     # (\\.\\/)?a_test\\.rb:5:(in `block \\(2 levels\\) in <top \\(required\\)>')?
\\.\\.\\*\\.

Pending:

x d \\(TODO\\)
(\\.\\/)?a_test\\.rb:14(\:in `block in <top \\(required\\)>')?

1\\)
'x a' FAILED
expected: 2,
     got: 1 \\(using ==\\)
(\\./)?a_test\\.rb:5:(in `block \\(2 levels\\) in <top \\(required\\)>')?
EXP

    output.should =~ Regexp.new(expected_output, 'x')
  end

  context 'Rspec 2.x' do
    before(:all)do
      @rspec_result = `cd spec/rspec_2 && bundle exec rspec a_test.rb --require ../../lib/rspec/instafail --format RSpec::Instafail --no-color`
    end
    before do
      @output = @rspec_result.dup
    end

    it "outputs logical failures" do
      expected = <<EXP
  1\\) x fails logically
     Failure\\/Error: 1\\.should == 2
     expected: 2,
     got: 1 \\(using ==\\)
EXP
      @output.should =~ Regexp.new(expected, 'x')

      @output.should include('/a_test.rb:5')
    end

    it 'outputs a simple error' do
      expected = <<EXP
\\.\\.\\*
  2\\) x raises a simple error
     Failure\\/Error: raise 'shallow failure'
     shallow failure
EXP
      @output.should =~ Regexp.new(expected, 'x')
    end

    it 'outputs an error which responds to original_exception' do
      expected = <<EXP
  3\\) x raises a hidden error
     Failure\\/Error: raise error
     There is an error in this error\\.
     There is no error in this error\\.
EXP
      @output.should =~ Regexp.new(expected, 'x')
    end
    it 'outputs the remaining passing specs and the ending block' do
      expected = <<EXP
\\.

Pending:
  x pends
    # No reason given
    # \\./a_test\\.rb:14

Finished in \\d\\.\\d+ seconds
7 examples, 3 failures, 1 pending
EXP
      @output.should =~ Regexp.new(expected, 'x')
    end

    it "works correctly with RSpec 2.x" do
      pending 'the backtrace for the error is always absolute on my machine'
      expected_output = <<EXP
  1\\) x a
     Failure\\/Error: 1\\.should == 2
     expected: 2,
     got: 1 \\(using ==\\)
     # \\./a_test\\.rb:5
\\.\\.\\*\\.

Pending:
  x d
    # No reason given
    # \\./a_test\\.rb:14

Finished in \\d\\.\\d+ seconds
7 examples, 3 failures, 1 pending
EXP
      @output.should =~ Regexp.new(expected_output, 'x')
    end
  end
end

