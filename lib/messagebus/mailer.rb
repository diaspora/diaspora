module Messagebus
  class Mailer
      unless defined?(MessagebusRubyApi::VERSION)
        MessagebusRubyApi::VERSION = '0.4.8'
      end

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

    def message_parse(string)
     string.split('<')[0] 
    end

    def from_header_parse(message)
     AppConfig[:smtp_sender_address]
     'no-reply@joindiaspora.com'
    end

    private

    def deliver(message)
      # here we want  = {:fromEmail => message['from'].to_s}
      #this is required due to weird bug in action mailer
      from_header = from_header_parse(message)

      @client.send_common_info = {:fromEmail => from_header, :customHeaders => {"sender"=> from_header}}
      message.to.each do |addressee|
        m = {:toEmail => addressee, :fromEmail => from_header, :subject => message.subject, :fromName => message_parse(from_header)}
        @things = []

        if message.multipart?
          m[:plaintextBody] = message.text_part.body.to_s if message.text_part
          m[:htmlBody]      = message.html_part.body.to_s if message.html_part
        else
          m[:plaintextBody] = message.body.to_s
          m[:htmlBody] = message.body.to_s
        end

        @client.add_message(m)
        @things << m
      end
      begin
        status = @client.flush
      rescue Exception => e
        raise "message bus failures: #{e.message} #{@things.map{|x| x[:fromEmail]}.inspect}, #{message['from']}"
      end
      if status[:failureCount] && status[:failureCount] > 0
        raise "Messagebus failure.  failureCount=#{status[:failureCount]}, message=#{message.inspect}"
      end
    end
  end
end
