require "rubygems"
begin
  require "rspec"
rescue LoadError
  require "spec"
end

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'yard'))

unless defined?(HAVE_RIPPER)
  begin require 'ripper'; rescue LoadError; end
  HAVE_RIPPER = defined?(::Ripper) && !ENV['LEGACY'] ? true : false
  LEGACY_PARSER = !HAVE_RIPPER
  
  class YARD::Parser::SourceParser
    def self.parser_type; :ruby18 end
  end if ENV['LEGACY']
end

def parse_file(file, thisfile = __FILE__, log_level = log.level, ext = '.rb.txt')
  Registry.clear
  path = File.join(File.dirname(thisfile), 'examples', file.to_s + ext)
  YARD::Parser::SourceParser.parse(path, [], log_level)
end

def described_in_docs(klass, meth, file = nil)
  YARD::Tags::Library.define_tag "RSpec Specification", :it, :with_raw_title_and_text

  # Parse the file (could be multiple files)
  if file
    filename = File.join(YARD::ROOT, file)
    YARD::Parser::SourceParser.new.parse(filename)
  else
    underscore = klass.class_name.gsub(/([a-z])([A-Z])/, '\1_\2').downcase.gsub('::', '/')
    $".find_all {|p| p.include? underscore }.each do |filename|
      next unless File.exists? filename
      YARD::Parser::SourceParser.new.parse(filename)
    end
  end
  
  # Get the object
  objname = klass.name + (meth[0,1] == '#' ? meth : '::' + meth)
  obj = Registry.at(objname)
  raise "Cannot find object #{objname} described by spec." unless obj
  raise "#{obj.path} has no @it tags to spec." unless obj.has_tag? :it
  
  # Run examples
  describe(klass, meth) do
    obj.tags(:it).each do |it|
      path = File.relative_path(YARD::ROOT, obj.file)
      it(it.name + " (from #{path}:#{obj.line})") do 
        begin
          eval(it.text)
        rescue => e
          e.set_backtrace(["#{path}:#{obj.line}:in @it tag specification"])
          raise e
        end
      end
    end
  end
end

def docspec(objname = self.class.description, klass = self.class.described_type)
  # Parse the file (could be multiple files)
  underscore = klass.class_name.gsub(/([a-z])([A-Z])/, '\1_\2').downcase.gsub('::', '/')
  $".find_all {|p| p.include? underscore }.each do |filename|
    filename = File.join(YARD::ROOT, filename)
    next unless File.exists? filename
    YARD::Parser::SourceParser.new.parse(filename)
  end
  
  # Get the object
  objname = klass.name + objname if objname =~ /^[^A-Z]/
  obj = Registry.at(objname)
  raise "Cannot find object #{objname} described by spec." unless obj
  raise "#{obj.path} has no @example tags to spec." unless obj.has_tag? :example
  
  # Run examples
  obj.tags(:example).each do |exs|
    exs.text.split(/\n/).each do |ex|
      begin
        hash = eval("{ #{ex} }")
        hash.keys.first.should == hash.values.first
      rescue => e
        raise e, "#{e.message}\nInvalid spec example in #{objname}:\n\n\t#{ex}\n"
      end
    end
  end
end

module Kernel
  require 'cgi'

  def p(*args)
    puts args.map {|arg| CGI.escapeHTML(arg.inspect) }.join("<br/>\n")
    args.first
  end
  
  def puts(str)
    STDOUT.puts str + "<br/>\n"
    str
  end
end if ENV['TM_APP_PATH']

include YARD
