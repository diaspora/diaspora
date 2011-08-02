require File.dirname(__FILE__) + '/../spec_helper'

include YARD::Templates

def only_copy?(result, example, type) 
  if $COPY == :all || $COPY == example
    puts(result) unless $COPYT && $COPYT != type
  end
  $COPY ? true : false
end

def text_equals(result, expected_example)
  return if only_copy?(result, expected_example, :text)
  text_equals_string(result, example_contents(expected_example, :txt))
end

def text_equals_string(result, expected)
  result.should == expected
end

def html_equals(result, expected_example)
  return if only_copy?(result, expected_example, :html)
  html_equals_string(result, example_contents(expected_example))
end

def html_equals_string(result, expected)
  [expected, result].each do |value|
    value.gsub!(/(>)\s+|\s+(<)/, '\1\2')
    value.strip!
  end
  text_equals_string(result, expected)
end

def example_contents(filename, ext = 'html')
  File.read(File.join(File.dirname(__FILE__), 'examples', "#{filename}.#{ext}"))
end

module YARD::Templates::Engine
  class << self
    public :find_template_paths
  end
end
