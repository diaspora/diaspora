require File.join(Rails.root, 'lib/diaspora/user/connecting')
require File.join(Rails.root, 'lib/diaspora/user/querying')

module Diaspora
  module UserModules
    include Connecting
    include Querying
  end
end
