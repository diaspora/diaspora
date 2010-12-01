module ChildProcess
  class AbstractIO
    attr_reader :stderr, :stdout

    def inherit!
      @stdout = STDOUT
      @stderr = STDERR
    end

    def stderr=(io)
      check_type io
      @stderr = io
    end

    def stdout=(io)
      check_type io
      @stdout = io
    end

    private

    def check_type(io)
      raise SubclassResponsibility, "check_type"
    end

  end
end
