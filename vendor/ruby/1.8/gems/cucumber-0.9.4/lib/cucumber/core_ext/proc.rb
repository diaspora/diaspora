# Proc extension to get more location info out of a proc
class Proc #:nodoc:
  PROC_PATTERN = /[\d\w]+@(.+):(\d+).*>/
  PWD = Dir.pwd
  
  def to_comment_line
    "# #{file_colon_line}"
  end

  def backtrace_line(name)
    "#{file_colon_line}:in `#{name}'"
  end

  if Proc.new{}.to_s =~ PROC_PATTERN
    def file_colon_line
      path, line = *to_s.match(PROC_PATTERN)[1..2]
      path = File.expand_path(path)
      pwd = File.expand_path(PWD)
      if path.index(pwd)
        path = path[pwd.length+1..-1]
      elsif path =~ /.*\/gems\/(.*\.rb)$/
        path = $1
      end
      "#{path}:#{line}"
    end
  else
    # This Ruby implementation doesn't implement Proc#to_s correctly
    STDERR.puts "*** THIS RUBY IMPLEMENTATION DOESN'T REPORT FILE AND LINE FOR PROCS ***"
    
    def file_colon_line
      "UNKNOWN:-1"
    end
  end
end 
