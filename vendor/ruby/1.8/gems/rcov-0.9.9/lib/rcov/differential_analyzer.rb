module Rcov
  class DifferentialAnalyzer
    require 'thread'
    @@mutex = Mutex.new

    def initialize(install_hook_meth, remove_hook_meth, reset_meth)
      @cache_state = :wait
      @start_raw_data = data_default
      @end_raw_data = data_default
      @aggregated_data = data_default
      @install_hook_meth = install_hook_meth
      @remove_hook_meth= remove_hook_meth
      @reset_meth= reset_meth
    end

    # Execute the code in the given block, monitoring it in order to gather
    # information about which code was executed.
    def run_hooked
      install_hook
      yield
    ensure
      remove_hook
    end

    # Start monitoring execution to gather information. Such data will be
    # collected until #remove_hook is called.
    #
    # Use #run_hooked instead if possible.
    def install_hook
      @start_raw_data = raw_data_absolute
      Rcov::RCOV__.send(@install_hook_meth)
      @cache_state = :hooked
      @@mutex.synchronize{ self.class.hook_level += 1 }
    end

    # Stop collecting information.
    # #remove_hook will also stop collecting info if it is run inside a
    # #run_hooked block.
    def remove_hook
      @@mutex.synchronize do 
        self.class.hook_level -= 1
        Rcov::RCOV__.send(@remove_hook_meth) if self.class.hook_level == 0
      end
      @end_raw_data = raw_data_absolute
      @cache_state = :done
      # force computation of the stats for the traced code in this run;
      # we cannot simply let it be if self.class.hook_level == 0 because 
      # some other analyzer could install a hook, causing the raw_data_absolute
      # to change again.
      # TODO: lazy computation of raw_data_relative, only when the hook gets
      # activated again.
      raw_data_relative
    end

    # Remove the data collected so far. Further collection will start from
    # scratch.
    def reset
      @@mutex.synchronize do
        if self.class.hook_level == 0
          # Unfortunately there's no way to report this as covered with rcov:
          # if we run the tests under rcov self.class.hook_level will be >= 1 !
          # It is however executed when we run the tests normally.
          Rcov::RCOV__.send(@reset_meth)
          @start_raw_data = data_default
          @end_raw_data = data_default
        else
          @start_raw_data = @end_raw_data = raw_data_absolute
        end
        @raw_data_relative = data_default
        @aggregated_data = data_default
      end
    end

    protected

    def data_default
      raise "must be implemented by the subclass"
    end

    def self.hook_level
      raise "must be implemented by the subclass"
    end

    def raw_data_absolute
      raise "must be implemented by the subclass"
    end

    def aggregate_data(aggregated_data, delta)
      raise "must be implemented by the subclass"
    end

    def compute_raw_data_difference(first, last)
      raise "must be implemented by the subclass"
    end

    private

    def raw_data_relative
      case @cache_state
      when :wait
        return @aggregated_data
      when :hooked
        new_start = raw_data_absolute
        new_diff = compute_raw_data_difference(@start_raw_data, new_start)
        @start_raw_data = new_start
      when :done
        @cache_state = :wait
        new_diff = compute_raw_data_difference(@start_raw_data, 
                                               @end_raw_data)
      end

      aggregate_data(@aggregated_data, new_diff)
      @aggregated_data
    end
  end
end