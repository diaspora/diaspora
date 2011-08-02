require 'capistrano/transfer'

module Capistrano
  class Configuration
    module Actions
      module FileTransfer

        # Store the given data at the given location on all servers targetted
        # by the current task. If <tt>:mode</tt> is specified it is used to
        # set the mode on the file.
        def put(data, path, options={})
          opts = options.dup
          upload(StringIO.new(data), path, opts)
        end
    
        # Get file remote_path from FIRST server targeted by
        # the current task and transfer it to local machine as path.
        #
        # get "#{deploy_to}/current/log/production.log", "log/production.log.web"
        def get(remote_path, path, options={}, &block)
          download(remote_path, path, options.merge(:once => true), &block)
        end

        def upload(from, to, options={}, &block)
          mode = options.delete(:mode)
          transfer(:up, from, to, options, &block)
          if mode
            mode = mode.is_a?(Numeric) ? mode.to_s(8) : mode.to_s
            run "chmod #{mode} #{to}", options
          end
        end

        def download(from, to, options={}, &block)
          transfer(:down, from, to, options, &block)
        end

        def transfer(direction, from, to, options={}, &block)
          execute_on_servers(options) do |servers|
            targets = servers.map { |s| sessions[s] }
            Transfer.process(direction, from, to, targets, options.merge(:logger => logger), &block)
          end
        end

      end
    end
  end
end
