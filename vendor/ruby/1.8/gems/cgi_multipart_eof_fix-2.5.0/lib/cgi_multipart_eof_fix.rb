
# unfortunately: 
# >> "1.8.6" < "1.8.10"
# => false

version = RUBY_VERSION.split(".").map {|i| i.to_i }

if version [0] < 2 and version [1] < 9 and version [2] < 6 and RUBY_PLATFORM !~ /java/

  STDERR.puts "** Ruby version is not up-to-date; loading cgi_multipart_eof_fix"  

  require 'cgi'  
  
  class CGI
    module QueryExtension
      def read_multipart(boundary, content_length)
        params = Hash.new([])
        boundary = "--" + boundary
        quoted_boundary = Regexp.quote(boundary, "n")
        buf = ""
        bufsize = 10 * 1024
        boundary_end=""
  
        # start multipart/form-data
        stdinput.binmode if defined? stdinput.binmode
        boundary_size = boundary.size + EOL.size
        content_length -= boundary_size
        status = stdinput.read(boundary_size)
        if nil == status
          raise EOFError, "no content body"
        elsif boundary + EOL != status
          raise EOFError, "bad content body #{status.inspect} expected, got #{(boundary + EOL).inspect}"
        end
  
        loop do
          head = nil
          if 10240 < content_length
            require "tempfile"
            body = Tempfile.new("CGI")
          else
            begin
              require "stringio"
              body = StringIO.new
            rescue LoadError
              require "tempfile"
              body = Tempfile.new("CGI")
            end
          end
          body.binmode if defined? body.binmode
  
          until head and /#{quoted_boundary}(?:#{EOL}|--)/n.match(buf)
  
            if (not head) and /#{EOL}#{EOL}/n.match(buf)
              buf = buf.sub(/\A((?:.|\n)*?#{EOL})#{EOL}/n) do
                head = $1.dup
                ""
              end
              next
            end
  
            if head and ( (EOL + boundary + EOL).size < buf.size )
              body.print buf[0 ... (buf.size - (EOL + boundary + EOL).size)]
              buf[0 ... (buf.size - (EOL + boundary + EOL).size)] = ""
            end
  
            c = if bufsize < content_length
                  stdinput.read(bufsize)
                else
                  stdinput.read(content_length)
                end
            if c.nil? || c.empty?
              raise EOFError, "bad content body"
            end
            buf.concat(c)
            content_length -= c.size
          end
  
          buf = buf.sub(/\A((?:.|\n)*?)(?:[\r\n]{1,2})?#{quoted_boundary}([\r\n]{1,2}|--)/n) do
            body.print $1
            if "--" == $2
              content_length = -1
            end
           boundary_end = $2.dup
            ""
          end
  
          body.rewind
  
          /Content-Disposition:.* filename="?([^\";]*)"?/ni.match(head)
  	filename = ($1 or "")
  	if /Mac/ni.match(env_table['HTTP_USER_AGENT']) and
  	    /Mozilla/ni.match(env_table['HTTP_USER_AGENT']) and
  	    (not /MSIE/ni.match(env_table['HTTP_USER_AGENT']))
  	  filename = CGI::unescape(filename)
  	end
          
          /Content-Type: (.*)/ni.match(head)
          content_type = ($1 or "")
  
          (class << body; self; end).class_eval do
            alias local_path path
            define_method(:original_filename) {filename.dup.taint}
            define_method(:content_type) {content_type.dup.taint}
          end
  
          /Content-Disposition:.* name="?([^\";]*)"?/ni.match(head)
          name = $1.dup
  
          if params.has_key?(name)
            params[name].push(body)
          else
            params[name] = [body]
          end
          break if buf.size == 0
          break if content_length === -1
        end
        raise EOFError, "bad boundary end of body part" unless boundary_end=~/--/
  
        params
      end # read_multipart
      private :read_multipart
    end
  end

else
  # Ruby version is up-to-date; cgi_multipart_eof_fix was not loaded
end
