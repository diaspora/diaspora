module NewRelic
  module Agent
    module Instrumentation
      module QueueTime
        unless defined?(MAIN_HEADER)
          MAIN_HEADER = 'HTTP_X_REQUEST_START'
          MIDDLEWARE_HEADER = 'HTTP_X_MIDDLEWARE_START'
          QUEUE_HEADER = 'HTTP_X_QUEUE_START'
          ALT_QUEUE_HEADER = 'HTTP_X_QUEUE_TIME'
          HEROKU_QUEUE_HEADER = 'HTTP_X_HEROKU_QUEUE_WAIT_TIME'
          APP_HEADER = 'HTTP_X_APPLICATION_START'

          HEADER_REGEX = /([^\s\/,(t=)]+)? ?t=([0-9]+)/
          SERVER_METRIC = 'WebFrontend/WebServer/'
          MIDDLEWARE_METRIC = 'Middleware/'
          # no individual queue metric - more than one queue?!
          ALL_SERVER_METRIC = 'WebFrontend/WebServer/all'
          ALL_MIDDLEWARE_METRIC = 'Middleware/all'
          ALL_QUEUE_METRIC = 'WebFrontend/QueueTime'
        end

        def parse_frontend_headers(headers)
          # these methods add internal state, so we dup so other parts
          # of the app don't have to worry about it.
          # May have performance implications with very large env hashes
          env = headers.dup
          add_end_time_header(Time.now, env)
          middleware_start = parse_middleware_time_from(env)
          queue_start = parse_queue_time_from(env)
          server_start = parse_server_time_from(env)
          # returned for the controller instrumentation
          [middleware_start, queue_start, server_start].min
        end

        private

        # main method to extract server time info from env hash,
        # records individual server metrics and one roll-up for all servers
        def parse_server_time_from(env)
          end_time = parse_end_time(env)
          matches = get_matches_from_header(MAIN_HEADER, env)

          record_individual_server_stats(end_time, matches)
          record_rollup_server_stat(end_time, matches)
        end

        def parse_middleware_time_from(env)
          end_time = parse_end_time(env)
          matches = get_matches_from_header(MIDDLEWARE_HEADER, env)

          record_individual_middleware_stats(end_time, matches)
          oldest_time = record_rollup_middleware_stat(end_time, matches)
          # notice this bit: we reset the end time to the earliest
          # middleware tag so that other frontend metrics don't
          # include this time.
          add_end_time_header(oldest_time, env)
          oldest_time
        end

        def parse_queue_time_from(env)
          oldest_time = nil
          end_time = parse_end_time(env)
          alternate_length = check_for_alternate_queue_length(env)
          if alternate_length
            # skip all that fancy-dan stuff
            NewRelic::Agent.get_stats(ALL_QUEUE_METRIC).trace_call(alternate_length)
            oldest_time = (end_time - alternate_length) # should be a time
          else
            matches = get_matches_from_header(QUEUE_HEADER, env)
            oldest_time = record_rollup_queue_stat(end_time, matches)
          end
          # notice this bit: we reset the end time to the earliest
          # queue tag or the start time minus the queue time so that
          # other frontend metrics don't include this time.
          add_end_time_header(oldest_time, env)
          oldest_time
        end

        def check_for_alternate_queue_length(env)
          heroku_length = check_for_heroku_queue_length(env)
          return heroku_length if heroku_length
          header = env[ALT_QUEUE_HEADER]
          return nil unless header
          (header.gsub('t=', '').to_i / 1_000_000.0)
        end

        def check_for_heroku_queue_length(env)
          header = env[HEROKU_QUEUE_HEADER]
          return nil unless header
          (header.gsub(/[^0-9]/, '').to_i / 1_000.0)
        end

        def get_matches_from_header(header, env)
          return [] if env.nil?
          get_matches(env[header]).map do |name, time|
            convert_to_name_time_pair(name, time)
          end
        end

        def get_matches(string)
          string.to_s.scan(HEADER_REGEX)
        end

        def convert_to_name_time_pair(name, time)
          [name, convert_from_microseconds(time.to_i)]
        end

        def record_individual_stat_of_type(type, end_time, matches)
          matches = matches.sort_by {|name, time| time }
          matches.reverse!
          matches.inject(end_time) {|end_time, pair|
            name, time = pair
            self.send(type, name, time, end_time) if name
            time
          }
        end

        # goes through the list of servers and records each one in
        # reverse order, subtracting the time for each successive
        # server from the earlier ones in the list.
        # an example because it's complicated:
        # start data:
        # [['a', Time.at(1000)], ['b', Time.at(1001)]], start time: Time.at(1002)
        # initial run: Time.at(1002), ['b', Time.at(1001)]
        # next: Time.at(1001), ['a', Time.at(1000)]
        # see tests for more
        def record_individual_server_stats(end_time, matches) # (Time, [[String, Time]]) -> nil
          record_individual_stat_of_type(:record_server_time_for, end_time, matches)
        end

        def record_individual_middleware_stats(end_time, matches)
          record_individual_stat_of_type(:record_middleware_time_for, end_time, matches)
        end

        # records the total time for all servers in a rollup metric
        def record_rollup_server_stat(end_time, matches) # (Time, [String, Time]) -> nil
          record_rollup_stat_of_type(ALL_SERVER_METRIC, end_time, matches)
        end

        def record_rollup_middleware_stat(end_time, matches)
          record_rollup_stat_of_type(ALL_MIDDLEWARE_METRIC, end_time, matches)
        end

        def record_rollup_queue_stat(end_time, matches)
          record_rollup_stat_of_type(ALL_QUEUE_METRIC, end_time, matches)
        end

        def record_rollup_stat_of_type(metric, end_time, matches)
          oldest_time = find_oldest_time(matches) || end_time
          record_time_stat(metric, oldest_time, end_time)
          oldest_time
        end

        # searches for the first server to touch a request
        def find_oldest_time(matches) # [[String, Time]] -> Time
          matches.map do |name, time|
            time
          end.min
        end

        # basically just assembles the metric name
        def record_server_time_for(name, start_time, end_time) # (Maybe String, Time, Time) -> nil
          record_time_stat(SERVER_METRIC + name, start_time, end_time) if name
        end

        def record_middleware_time_for(name, start_time, end_time)
          record_time_stat(MIDDLEWARE_METRIC + name, start_time, end_time)
        end

        # Checks that the time is not negative, and does the actual
        # data recording
        def record_time_stat(name, start_time, end_time) # (String, Time, Time) -> nil
          total_time = end_time - start_time
          if total_time < 0
            raise "should not provide an end time less than start time: #{end_time} is less than #{start_time}"
          else
            NewRelic::Agent.get_stats(name).trace_call(total_time)
          end
        end

        def add_end_time_header(end_time, env) # (Time, Env) -> nil
          return unless end_time
          env[APP_HEADER] = "t=#{convert_to_microseconds(end_time)}"
        end

        def parse_end_time(env)
          header = env[APP_HEADER]
          return Time.now unless header
          convert_from_microseconds(header.gsub('t=', '').to_i)
        end

        # convert a time to the value provided by the header, for convenience
        def convert_to_microseconds(time) # Time -> Int
          raise TypeError.new('Cannot convert a non-time into microseconds') unless time.is_a?(Time) || time.is_a?(Numeric)
          return time if time.is_a?(Numeric)
          (time.to_f * 1_000_000).to_i
        end

        # convert a time from the header value (time in microseconds)
        # into a ruby time object
        def convert_from_microseconds(int) # Int -> Time
          raise TypeError.new('Cannot convert a non-number into a time') unless int.is_a?(Time) || int.is_a?(Numeric)
          return int if int.is_a?(Time)
          Time.at((int / 1_000_000.0))
        end
      end
    end
  end
end

