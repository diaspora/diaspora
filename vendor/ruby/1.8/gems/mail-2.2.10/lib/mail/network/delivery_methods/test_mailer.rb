module Mail
  # The TestMailer is a bare bones mailer that does nothing.  It is useful
  # when you are testing.
  # 
  # It also provides a template of the minimum methods you require to implement
  # if you want to make a custom mailer for Mail
  class TestMailer

    # Provides a store of all the emails sent with the TestMailer so you can check them.
    def TestMailer.deliveries
      @@deliveries ||= []
    end

    # Allows you to over write the default deliveries store from an array to some
    # other object.  If you just want to clear the store, 
    # call TestMailer.deliveries.clear.
    # 
    # If you place another object here, please make sure it responds to:
    # 
    # * << (message)
    # * clear
    # * length
    # * size
    # * and other common Array methods
    def TestMailer.deliveries=(val)
      @@deliveries = val
    end

    def initialize(values)
      @settings = {}
    end
    
    attr_accessor :settings

    def deliver!(mail)
      Mail::TestMailer.deliveries << mail
    end
    
  end
end