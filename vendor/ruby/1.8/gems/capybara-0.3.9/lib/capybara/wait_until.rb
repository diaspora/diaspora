module Capybara
  #Provides timeout similar to standard library Timeout, but avoids threads
  class WaitUntil

    class << self

      def timeout(seconds = 1, driver = nil, &block)
        start_time = Time.now

        result = nil

        until result
          return result if result = yield

          delay = seconds - (Time.now - start_time)
          if delay <= 0
            raise TimeoutError
          end

          driver && driver.wait_until(delay)

          sleep(0.05)
        end
      end

    end
  end
end
