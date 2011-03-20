#   Copyright (c) 2010, Diaspora Inc.  This file is
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
    proc {
      ResqueJobLoggingDummy.around_perform_log_job("stuff"){raise "GRAAAAAAAAAGH"}
    }.should raise_error

  end
end
