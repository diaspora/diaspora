rspec-expectations is used to set expectations in executable
examples:

    describe Account do
      it "has a balance of zero when first created" do
        Account.new.balance.should eq(Money.new(0))
      end
    end

## Issues

The documentation for rspec-expectations is a work in progress. We'll be adding
Cucumber features over time, and clarifying existing ones.  If you have
specific features you'd like to see added, find the existing documentation
incomplete or confusing, or, better yet, wish to write a missing Cucumber
feature yourself, please [submit an
issue](http://github.com/rspec/rspec-expectations/issues) or a [pull
request](http://github.com/rspec/rspec-expectations).
