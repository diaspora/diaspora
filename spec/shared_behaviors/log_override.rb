class FakeLogger
  attr_accessor :infos
  attr_accessor :lines
  attr_accessor :fatals

  def initialize
    self.infos = []
    self.fatals = []
    self.lines = []
  end

  def add(arg1, line, targ_arr, &block)
    self.lines << line
    targ_arr << line
  end
  def info line
    self.add(nil, line, self.infos)
  end
  def fatal line
    self.add(nil, line, self.fatals)
  end

  include SplunkLogging
end

shared_examples_for 'it overrides the logs on success' do
  before do
    Rails.stub(:logger).and_return(FakeLogger.new)
  end
  context 'rendering' do
    it 'logs renders' do
      get @action, @action_params
      @lines = Rails.logger.infos.select { |l| l.include?("event=render") }
      @lines.length.should > 0
    end
  end
  context 'completion' do
    context 'ok' do
      before do
        get @action, @action_params
        @line = Rails.logger.infos.last
      end
      it 'logs the completion of a request' do
        @line.include?("event=request_completed").should be_true
      end
      it 'logs an ok' do
        @line.include?("status=200").should be_true
      end
      it 'logs the controller' do
        @line.include?("controller='#{controller.class.name}'").should be_true
      end
      it 'logs the action' do
        @line.include?("action='#{@action}'").should be_true
      end
      it 'logs params' do
        if @action_params
          @line.include?("params='#{@action_params.inspect.gsub(" ", "")}'").should be_true
        end
      end
      it 'does not log the view rendering time addition' do
        @line.include?("view_ms=").should be_true
      end
    end
  end
end

shared_examples_for 'it overrides the logs on error' do
  before do
    Rails.stub(:logger).and_return(FakeLogger.new)
    begin
      get @action, @action_params
    rescue Exception => e
      ActionDispatch::ShowExceptions.new(nil).send(:log_error,e)
    end
    @line = Rails.logger.lines.last
  end
  it 'logs the backtrace' do
    @line.should =~ /app_backtrace=/
  end
  it 'logs the error message' do
    @line.should =~ /error_message='#{@desired_error_message}'/
  end
  it 'logs the original error message, if it exists' do
    @line.should =~ /orig_error_message='#{@orig_error_message}'/ if @orig_error_message
  end
end

shared_examples_for 'it overrides the logs on redirect' do
  before do
    Rails.stub(:logger).and_return(FakeLogger.new)
    get @action, @action_params
    @line = Rails.logger.infos.last
  end
  it 'logs a redirect' do
    @line.include?("status=302").should be_true
  end
end
