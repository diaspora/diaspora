# Require this file if you need Unicode support.
# Tips for improvement - esp. ruby 1.9: http://www.ruby-forum.com/topic/184730
require 'cucumber/platform'
require 'cucumber/formatter/ansicolor'
$KCODE='u' unless Cucumber::RUBY_1_9

if Cucumber::WINDOWS
  require 'iconv'

  if ENV['CUCUMBER_OUTPUT_ENCODING']
    Cucumber::CODEPAGE = ENV['CUCUMBER_OUTPUT_ENCODING']
  elsif Cucumber::WINDOWS_MRI
    Cucumber::CODEPAGE = "cp#{Win32::Console::OutputCP()}"
  elsif `cmd /c chcp` =~ /(\d+)/
    Cucumber::CODEPAGE = "cp#{$1.to_i}"
  else
    Cucumber::CODEPAGE = "cp1252"
    STDERR.puts("WARNING: Couldn't detect your output codepage. Assuming it is 1252. You may have to chcp 1252 or SET CUCUMBER_OUTPUT_ENCODING=cp1252.")
  end

  module Cucumber
    module WindowsOutput #:nodoc:
      def self.extended(o)
        o.instance_eval do
          alias cucumber_print print
          def print(*a)
            begin
              cucumber_print(*Iconv.iconv(Cucumber::CODEPAGE, "UTF-8", *a.map{|a|a.to_s}))
            rescue Iconv::InvalidEncoding => e
              STDERR.cucumber_puts("WARNING: #{e.message}")
              cucumber_print(*a)
            rescue Iconv::IllegalSequence => e
              STDERR.cucumber_puts("WARNING: #{e.message}")
              cucumber_print(*a)
            end
          end

          alias cucumber_puts puts
          def puts(*a)
            begin
              cucumber_puts(*Iconv.iconv(Cucumber::CODEPAGE, "UTF-8", *a.map{|a|a.to_s}))
            rescue Iconv::InvalidEncoding => e
              STDERR.cucumber_print("WARNING: #{e.message}")
              cucumber_print(*a)
            rescue Iconv::IllegalSequence => e
              STDERR.cucumber_puts("WARNING: #{e.message}")
              cucumber_puts(*a)
            end
          end
        end
      end

      Kernel.extend(self)
      STDOUT.extend(self)
      STDERR.extend(self)
    end
  end
end
