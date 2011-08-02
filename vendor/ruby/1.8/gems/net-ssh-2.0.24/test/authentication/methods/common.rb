module Authentication; module Methods

  module Common
    include Net::SSH::Authentication::Constants

    private

      def socket(options={})
        @socket ||= stub("socket", :client_name => "me.ssh.test")
      end

      def transport(options={})
        @transport ||= MockTransport.new(options.merge(:socket => socket))
      end

      def session(options={})
        @session ||= begin
          sess = stub("auth-session", :logger => nil, :transport => transport(options))
          def sess.next_message
            transport.next_message
          end
          sess
        end
      end

  end

end; end