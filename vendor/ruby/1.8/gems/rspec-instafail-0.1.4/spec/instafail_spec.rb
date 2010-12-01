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

  it "works correctly with RSpec 2.x (but backtrace might be broken)" do
    output = `cd spec/rspec_2 && bundle exec rspec a_test.rb --require ../../lib/rspec/instafail --format RSpec::Instafail --no-color`
    expected = <<EXP
  1\\) x a
     Failure\\/Error: 1\\.should == 2
     expected: 2,
     got: 1 \\(using ==\\)
EXP
    output.should =~ Regexp.new(expected, 'x')

    output.should include('/a_test.rb:5')

    expected = <<EXP
\\.\\.\\*\\.

Pending:
  x d
    # No reason given
    # \\./a_test\\.rb:14

Finished in \\d\\.\\d+ seconds
5 examples, 1 failure, 1 pending
EXP
    output.should =~ Regexp.new(expected, 'x')

  end

  it "works correctly with RSpec 2.x" do
    pending 'the backtrace for the error is always absolute on my machine'
    output = `cd spec/rspec_2 && bundle exec rspec a_test.rb --require ../../lib/rspec/instafail --format RSpec::Instafail --no-color`
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
5 examples, 1 failure, 1 pending
EXP

    output.should =~ Regexp.new(expected_output, 'x')

  end
end

