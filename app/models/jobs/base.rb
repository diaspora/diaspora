#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  class Base
    Dir["#{Rails.root}/app/models/jobs/mail/*.rb"].each {|file| require file }
    
    #TODO these should be subclassed real exceptions
    DUMB_ERROR_MESSAGES = [
      "Contact required unless request",
      "Relayable object, but no parent object found" ]

    def self.suppress_annoying_errors(&block)
      begin
        yield
      rescue Exception => e
        if DUMB_ERROR_MESSAGES.include?(e.message)
          Rails.logger.error(e.message)
        else
          raise e
        end
      end
    end
  end
end