require File.join(Rails.root, 'lib/diaspora/user/friending')
require File.join(Rails.root, 'lib/diaspora/user/querying')
require File.join(Rails.root, 'lib/diaspora/user/receiving')

module Diaspora
  module UserModules
    include Friending
    include Querying
    include Receiving
  end
end
