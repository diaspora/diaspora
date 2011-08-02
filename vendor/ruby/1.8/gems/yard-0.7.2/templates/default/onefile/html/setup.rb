include T('default/layout/html')
include YARD::Parser::Ruby::Legacy

def init
  override_serializer  
  @object = YARD::Registry.root
  @files.shift
  @objects.delete(YARD::Registry.root)
  @objects.unshift(YARD::Registry.root)
  sections :layout, [:readme, :files, :all_objects]
end

def all_objects
  @objects.map {|obj| obj.format(options) }.join("\n")
end

private

def parse_top_comments_from_file
  return @readme.contents unless @readme.filename =~ /\.rb$/
  data = ""
  tokens = TokenList.new(@readme.contents)
  tokens.each do |token|
    break unless token.is_a?(RubyToken::TkCOMMENT) || token.is_a?(RubyToken::TkNL)
    data << (token.text[/\A#\s{0,1}(.*)/, 1] || "\n")
  end
  YARD::Docstring.new(data)
end

def override_serializer
  return if @serializer.nil?
  class << @serializer
    def serialize(object, data)
      return unless object == 'index.html'
      super
    end
    
    def serialized_path(object)
      return object if object.is_a?(String)
      return 'index.html'
    end
  end
end