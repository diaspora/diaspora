if defined?(ActiveRecord::Base)
  Before do
    $__cucumber_global_use_txn = !!Cucumber::Rails::World.use_transactional_fixtures if $__cucumber_global_use_txn.nil?
  end

  Before('~@no-txn', '~@selenium', '~@culerity', '~@celerity', '~@javascript') do
    Cucumber::Rails::World.use_transactional_fixtures = $__cucumber_global_use_txn
  end

  Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
    Cucumber::Rails::World.use_transactional_fixtures = false
  end

  Before do
    if Cucumber::Rails::World.use_transactional_fixtures
      run_callbacks :setup if respond_to?(:run_callbacks)
    else
      DatabaseCleaner.start
    end
    ActionMailer::Base.deliveries = [] if defined?(ActionMailer::Base)
  end

  After do
    if Cucumber::Rails::World.use_transactional_fixtures
      run_callbacks :teardown if respond_to?(:run_callbacks)
    else
      DatabaseCleaner.clean
    end
  end
else
  module Cucumber::Rails
    def World.fixture_table_names; []; end # Workaround for projects that don't use ActiveRecord
  end
end
