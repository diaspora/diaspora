module Typhoeus
  class Multi
    attr_reader :easy_handles

    def initialize
      @easy_handles = []
    end

    def remove(easy)
      multi_remove_handle(easy) if @easy_handles.include?(easy)
    end

    def add(easy)
      raise "trying to add easy handle twice" if @easy_handles.include?(easy)
      easy.set_headers() if easy.headers.empty?
      multi_add_handle(easy)
    end

    def perform()
      while active_handle_count > 0 do
        multi_perform
      end
      reset_easy_handles
    end

    def cleanup()
      multi_cleanup
    end

    def reset_easy_handles
      @easy_handles.dup.each do |easy|
        multi_remove_handle(easy)
        yield easy if block_given?
      end
    end
  end
end
