def init
  super
  options[:serializer].serialize('/images/bubble_32x32.png', IO.read(File.dirname(__FILE__) + '/bubble_32x32.png'))
end
