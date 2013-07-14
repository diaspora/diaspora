module Workers
  class PostToApp < Base
    sidekiq_options queue: :http_service

    def perform(callback_url, params)
      begin
        connection = Faraday.new
        connection.post callback_url, params
      rescue Exception => e
        return nil
      end
    end
  end
end