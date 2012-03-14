require 'will_paginate/array'

# Optional for Bootstrap :renderer => WillPaginate::ActionView::BootstrapLinkRenderer
# https://github.com/yrgoldteeth/bootstrap-will_paginate

module WillPaginate
  module ActionView
    def will_paginate(collection = nil, options = { :renderer => WillPaginate::ActionView::LinkRenderer } )
      super.try :html_safe
    end
  end
end
