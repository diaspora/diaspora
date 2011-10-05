module Messagebus
  class Mailer

    def initialize(api_key)
      @client = MessagebusRubyApi::Client.new(api_key)
    end

    attr_accessor :settings

    def new(*settings)
      self
    end

    def deliver!(message)
      deliver(message)
    end

    private

    def deliver(message)
      puts "dslkfjasd;lfkjasd;lkfjasd;lkfjasd;lkfjasd;lfjkasd;lkfjasd;lfkjasd;lfkjasd;lkfjas;ldkfj;alsdkjf;lasdjkf;lasdkjf;alsdjkfls"
      @client.common_info = {:fromEmail => message.from.first}
      message.to.each do |addressee|
        m = {:toEmail => addressee, :subject => message.subject}

        if message.multipart?
          m[:plaintextBody] = message.text_part.body.to_s if message.text_part
          m[:htmlBody]      = message.html_part.body.to_s if message.html_part
        else
          m[:plaintextBody] = message.body.to_s
        end

        @client.add_message(m)
      end

      status = @client.flush

      if status[:failureCount] && status[:failureCount] > 0
        raise "Messagebus failure.  failureCount=#{failureCount}, message=#{message.inspect}"
      end

    end
    
  end

end
