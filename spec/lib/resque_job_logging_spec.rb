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
