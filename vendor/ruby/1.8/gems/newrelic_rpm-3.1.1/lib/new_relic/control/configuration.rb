module NewRelic
  class Control
    # used to contain methods to look up settings from the
    # configuration located in newrelic.yml
    module Configuration
      def settings
        unless @settings
          @settings = (@yaml && merge_defaults(@yaml[env])) || {}
          # At the time we bind the settings, we also need to run this little piece
          # of magic which allows someone to augment the id with the app name, necessary
          if self['multi_homed'] && app_names.size > 0
            if @local_env.dispatcher_instance_id
              @local_env.dispatcher_instance_id << ":#{app_names.first}"
            else
              @local_env.dispatcher_instance_id = app_names.first
            end
          end

        end
        @settings
      end

      def merge_defaults(settings_hash)
        s = {
          'host' => 'collector.newrelic.com',
          'ssl' => false,
          'log_level' => 'info',
          'apdex_t' => 0.5
        }
        s.merge! settings_hash if settings_hash
        # monitor_daemons replaced with agent_enabled
        s['agent_enabled'] = s.delete('monitor_daemons') if s['agent_enabled'].nil? && s.include?('monitor_daemons')
        s
      end

      # Merge the given options into the config options.
      # They might be a nested hash
      def merge_options(options, hash=self)
        options.each do |key, val |
          case
          when key == :config then next
          when val.is_a?(Hash)
            merge_options(val, hash[key.to_s] ||= {})
          when val.nil?
            hash.delete(key.to_s)
          else
            hash[key.to_s] = val
          end
        end
      end

      def [](key)
        fetch(key)
      end

      def []=(key, value)
        settings[key] = value
      end

      def fetch(key, default=nil)
        settings.fetch(key, default)
      end

      def apdex_t
        # Always initialized with a default
        fetch('apdex_t').to_f
      end

      def license_key
        fetch('license_key', ENV['NEWRELIC_LICENSE_KEY'])
      end
      
      def capture_params
        fetch('capture_params')
      end
      
      # True if we are sending data to the server, monitoring production
      def monitor_mode?
        fetch('monitor_mode', fetch('enabled'))
      end

      # True if we are capturing data and displaying in /newrelic
      def developer_mode?
        fetch('developer_mode', fetch('developer'))
      end
      
      # whether we should install the
      # NewRelic::Rack::BrowserMonitoring middleware automatically on
      # Rails applications
      def browser_monitoring_auto_instrument?
        fetch('browser_monitoring', {}).fetch('auto_instrument', true)
      end

      def multi_threaded?
        fetch('multi_threaded')
      end

      def disable_serialization?
        fetch('disable_serialization', false)
      end
      def disable_serialization=(b)
        self['disable_serialization'] = b
      end
      
      # True if we should view files in textmate
      def use_textmate?
        fetch('textmate')
      end
      
      # defaults to 2MiB
      def post_size_limit
        fetch('post_size_limit', 2 * 1024 * 1024)
      end

      # Configuration option of the same name to indicate that we should connect
      # to New Relic synchronously on startup.  This means when the agent is loaded it
      # won't return without trying to set up the server connection at least once
      # which can make startup take longer.  Defaults to false.
      def sync_startup
        fetch('sync_startup', false)
      end

      # Configuration option of the same name to indicate that we should flush
      # data to the server on exiting.  Defaults to true.
      def send_data_on_exit
        fetch('send_data_on_exit', true)
      end

      def dispatcher_instance_id
        self['dispatcher_instance_id'] || @local_env.dispatcher_instance_id
      end

      def dispatcher
        (self['dispatcher'] && self['dispatcher'].to_sym) || @local_env.dispatcher
      end
      def app_names
        case self['app_name']
        when Array then self['app_name']
        when String then self['app_name'].split(';')
        else [ env ]
        end
      end
      def validate_seed
        self['validate_seed'] || ENV['NR_VALIDATE_SEED']
      end
      def validate_token
        self['validate_token'] || ENV['NR_VALIDATE_TOKEN']
      end
      
      def use_ssl?
        @use_ssl = fetch('ssl', false) unless @use_ssl
        @use_ssl
      end
      
      def log_file_path
        fetch('log_file_path', 'log/')
      end
      
      # only verify certificates if you're very sure you want this
      # level of security, it includes possibly app-crashing dns
      # lookups every connection to the server
      def verify_certificate?
        unless @verify_certificate
          unless use_ssl?
            @verify_certificate = false
          else
            @verify_certificate = fetch('verify_certificate', false)
          end
        end
        @verify_certificate
      end

      def disable_backtrace_cleanup?
        fetch('disable_backtrace_cleanup')
      end
    end
    include Configuration
  end
end
