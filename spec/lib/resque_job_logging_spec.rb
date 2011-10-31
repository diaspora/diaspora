#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ResqueJobLogging do
  before do
    Rails.stub!(:logger).and_return(mock())
    Rails.logger.should_receive(:auto_flushing=).with(1)

    silence_warnings { Object.const_set("ResqueJobLoggingDummy", Class.new(Object)) }
    ResqueJobLoggingDummy.extend(ResqueJobLogging)
  end

  after do
    Rails.unstub!(:logger)
  end

  # http://bugs.joindiaspora.com/issues/741
  it "should enumerate arguments" do
    Rails.logger.should_receive(:info).with(/arg1="foo" arg2="bar" arg3="baz"/)
    ## pass a nil block, so we can test the .info() output
    ResqueJobLoggingDummy.around_perform_log_job("foo", "bar", "baz") {}
  end
  it 'logs stack traces on failure' do
    Rails.logger.should_receive(:info).with(/app_backtrace=/)
    error = RuntimeError.new("GRAAAAAAAAAGH")
    proc {
      ResqueJobLoggingDummy.around_perform_log_job("stuff"){raise error}
    }.should raise_error(Regexp.new(error.message))
  end

  it 'notifies hoptoad if the hoptoad api key is set' do
    Rails.logger.should_receive(:info)
    AppConfig.should_receive(:[]).with(:hoptoad_api_key).and_return("what")
    error = RuntimeError.new("GRAAAAAAAAAGH")
    ResqueJobLoggingDummy.should_receive(:notify_hoptoad).with(error, ["stuff"])
    proc {
      ResqueJobLoggingDummy.around_perform_log_job("stuff"){raise error }
    }.should raise_error(Regexp.new(error.message))
  end
end
