# Require this file if you need Unicode support.
# Tips for improvement - esp. ruby 1.9: http://www.ruby-forum.com/topic/184730
require 'cucumber/platform'
require 'cucumber/formatter/ansicolor'
$KCODE='u' unless Cucumber::RUBY_1_9

if Cucumber::WINDOWS
  require 'iconv' unless Cucumber::RUBY_1_9

  if ENV['CUCUMBER_OUTPUT_ENCODING']
    Cucumber::CODEPAGE = ENV['CUCUMBER_OUTPUT_ENCODING']
  elsif `cmd /c chcp` =~ /(\d+)/
    if [65000, 65001].include? $1.to_i
      Cucumber::CODEPAGE = 'UTF-8'
      ENV['ANSICON_API'] = 'ruby'
    else
      Cucumber::CODEPAGE = "cp#{$1.to_i}"
    end
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
            if Cucumber::RUBY_1_9
              begin
                cucumber_print(*a.map{|arg| arg.to_s.encode(Encoding.default_external)})
              rescue Encoding::UndefinedConversionError => e
                STDERR.cucumber_puts("WARNING: #{e.message}")
                cucumber_print(*a)
              end
            else
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
          end

          alias cucumber_puts puts
          def puts(*a)
            if Cucumber::RUBY_1_9
              begin
                cucumber_puts(*a.map{|arg| arg.to_s.encode(Encoding.default_external)})
              rescue Encoding::UndefinedConversionError => e
                STDERR.cucumber_puts("WARNING: #{e.message}")
                cucumber_puts(*a)
              end
            else
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
      end

      Kernel.extend(self)
      STDOUT.extend(self)
      STDERR.extend(self)
    end
  end
end
