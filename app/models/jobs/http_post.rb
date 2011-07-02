#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class HttpPost < Base 
    @queue = :http
    NUM_TRIES = 3

    def self.perform_delegate(url, body, tries_remaining = NUM_TRIES)
      begin
        body = CGI::escape(body)
        RestClient.post(url, :xml => body){ |response, request, result, &block|
          if [301, 302, 307].include? response.code
            response.follow_redirection(request, result, &block)
          else
            response.return!(request, result, &block)
          end
        }
      rescue Exception => e
        unless tries_remaining <= 1
          Resque.enqueue(self, url, body, tries_remaining -1)
        else
          raise e
        end
      end
    end
  end
end
