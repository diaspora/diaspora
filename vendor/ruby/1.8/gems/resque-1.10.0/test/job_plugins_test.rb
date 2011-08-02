require File.dirname(__FILE__) + '/test_helper'

context "Multiple plugins with multiple hooks" do
  include PerformJob

  module Plugin1
    def before_perform_record_history1(history)
      history << :before1
    end
    def after_perform_record_history1(history)
      history << :after1
    end
  end

  module Plugin2
    def before_perform_record_history2(history)
      history << :before2
    end
    def after_perform_record_history2(history)
      history << :after2
    end
  end

  class ::ManyBeforesJob
    extend Plugin1
    extend Plugin2
    def self.perform(history)
      history << :perform
    end
  end

  test "hooks of each type are executed in alphabetical order" do
    result = perform_job(ManyBeforesJob, history=[])
    assert_equal true, result, "perform returned true"
    assert_equal [:before1, :before2, :perform, :after1, :after2], history
  end
end

context "Resque::Plugin ordering before_perform" do
  include PerformJob

  module BeforePerformPlugin
    def before_perform1(history)
      history << :before_perform1
    end
  end

  class ::BeforePerformJob
    extend BeforePerformPlugin
    def self.perform(history)
      history << :perform
    end
    def self.before_perform(history)
      history << :before_perform
    end
  end

  test "before_perform hooks are executed in order" do
    result = perform_job(BeforePerformJob, history=[])
    assert_equal true, result, "perform returned true"
    assert_equal [:before_perform, :before_perform1, :perform], history
  end
end

context "Resque::Plugin ordering after_perform" do
  include PerformJob

  module AfterPerformPlugin
    def after_perform_record_history(history)
      history << :after_perform1
    end
  end

  class ::AfterPerformJob
    extend AfterPerformPlugin
    def self.perform(history)
      history << :perform
    end
    def self.after_perform(history)
      history << :after_perform
    end
  end

  test "after_perform hooks are executed in order" do
    result = perform_job(AfterPerformJob, history=[])
    assert_equal true, result, "perform returned true"
    assert_equal [:perform, :after_perform, :after_perform1], history
  end
end

context "Resque::Plugin ordering around_perform" do
  include PerformJob

  module AroundPerformPlugin1
    def around_perform1(history)
      history << :around_perform_plugin1
      yield
    end
  end

  class ::AroundPerformJustPerformsJob
    extend AroundPerformPlugin1
    def self.perform(history)
      history << :perform
    end
  end

  test "around_perform hooks are executed before the job" do
    result = perform_job(AroundPerformJustPerformsJob, history=[])
    assert_equal true, result, "perform returned true"
    assert_equal [:around_perform_plugin1, :perform], history
  end

  class ::AroundPerformJob
    extend AroundPerformPlugin1
    def self.perform(history)
      history << :perform
    end
    def self.around_perform(history)
      history << :around_perform
      yield
    end
  end

  test "around_perform hooks are executed in order" do
    result = perform_job(AroundPerformJob, history=[])
    assert_equal true, result, "perform returned true"
    assert_equal [:around_perform, :around_perform_plugin1, :perform], history
  end

  module AroundPerformPlugin2
    def around_perform2(history)
      history << :around_perform_plugin2
      yield
    end
  end

  class ::AroundPerformJob2
    extend AroundPerformPlugin1
    extend AroundPerformPlugin2
    def self.perform(history)
      history << :perform
    end
    def self.around_perform(history)
      history << :around_perform
      yield
    end
  end

  test "many around_perform are executed in order" do
    result = perform_job(AroundPerformJob2, history=[])
    assert_equal true, result, "perform returned true"
    assert_equal [:around_perform, :around_perform_plugin1, :around_perform_plugin2, :perform], history
  end

  module AroundPerformDoesNotYield
    def around_perform0(history)
      history << :around_perform0
    end
  end

  class ::AroundPerformJob3
    extend AroundPerformPlugin1
    extend AroundPerformPlugin2
    extend AroundPerformDoesNotYield
    def self.perform(history)
      history << :perform
    end
    def self.around_perform(history)
      history << :around_perform
      yield
    end
  end

  test "the job is aborted if an around_perform hook does not yield" do
    result = perform_job(AroundPerformJob3, history=[])
    assert_equal false, result, "perform returned false"
    assert_equal [:around_perform, :around_perform0], history
  end

  module AroundPerformGetsJobResult
    @@result = nil
    def last_job_result
      @@result
    end

    def around_perform_gets_job_result(*args)
      @@result = yield
    end
  end

  class ::AroundPerformJobWithReturnValue < GoodJob
    extend AroundPerformGetsJobResult
  end

  test "the job is aborted if an around_perform hook does not yield" do
    result = perform_job(AroundPerformJobWithReturnValue, 'Bob')
    assert_equal true, result, "perform returned true"
    assert_equal 'Good job, Bob', AroundPerformJobWithReturnValue.last_job_result
  end
end

context "Resque::Plugin ordering on_failure" do
  include PerformJob

  module OnFailurePlugin
    def on_failure1(exception, history)
      history << "#{exception.message} plugin"
    end
  end

  class ::FailureJob
    extend OnFailurePlugin
    def self.perform(history)
      history << :perform
      raise StandardError, "oh no"
    end
    def self.on_failure(exception, history)
      history << exception.message
    end
  end

  test "on_failure hooks are executed in order" do
    history = []
    assert_raises StandardError do
      perform_job(FailureJob, history)
    end
    assert_equal [:perform, "oh no", "oh no plugin"], history
  end
end
