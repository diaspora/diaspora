class FakeLogger
  attr_accessor :infos

  def initialize
    self.infos = []
  end

  def info line
    self.infos << line
  end
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
        @line.include?('event=request_completed').should be_true
      end
      it 'logs an ok' do
        @line.include?('status=200').should be_true
      end
      it 'logs the controller' do
        @line.include?("controller=#{controller.class.name}").should be_true
      end
      it 'logs the action' do
        @line.include?("action=#{@action}").should be_true
      end
      it 'logs params' do
        if @action_params
          @line.include?("params='#{@action_params.inspect.gsub(" ", "")}'").should be_true
        end
      end
      it 'does not log the view rendering time addition' do
        @line.include?("(Views: ").should be_false
      end
    end
  end
end

shared_examples_for 'it overrides the logs on redirect' do
  before do
    Rails.stub(:logger).and_return(FakeLogger.new)
    get @action, @action_params
    @line = Rails.logger.infos.last
  end
  it 'logs a redirect' do
    @line.include?('status=302').should be_true
  end
end
