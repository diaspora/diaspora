require "stringio"

# To use as a parameter to Merb::Template.inline_template
class VirtualFile < StringIO
  attr_accessor :path
  def initialize(string, path)
    super(string)
    @path = path
  end
end
