require File.join(Rails.root, 'lib/diaspora/user/connecting')
require File.join(Rails.root, 'lib/diaspora/user/querying')
require File.join(Rails.root, 'lib/diaspora/user/receiving')

module Diaspora
  module UserModules
    include Connecting
    include Querying
    include Receiving
  end
end
