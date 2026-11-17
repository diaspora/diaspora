# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# rubocop:disable Style/OneClassPerFile

module NoOpWorkerStub
  def perform_async(*args)
    new.perform(*args)
  end

  def perform_in(*args)
    perform_async(*args.drop(1))
  end
end

class SendPrivateWorker
  extend NoOpWorkerStub

  def perform(*_args)
    # don't federate in cucumber
  end
end

class SendPublicWorker
  extend NoOpWorkerStub

  def perform(*_args)
    # don't federate in cucumber
  end
end

class FetchWebfingerWorker
  extend NoOpWorkerStub

  def perform(*_args)
    # don't do real discovery in cucumber
  end
end

# rubocop:enable Style/OneClassPerFile
