warn <<-MSG
[DEPRECATION] loading activerecord-import via 'require "activerecord-import/<adapter-name>"'
  is deprecated. Update to autorequire using 'require "activerecord-import"'. See
  http://github.com/zdennis/activerecord-import/wiki/Requiring for more information
MSG

require File.expand_path(File.join(File.dirname(__FILE__),  "/../activerecord-import"))

