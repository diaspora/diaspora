require 'will_paginate'
require 'will_paginate/collection'

module WillPaginate
  class Railtie < Rails::Railtie
    initializer "will_paginate.active_record" do |app|
      if defined? ::ActiveRecord
        require 'will_paginate/finders/active_record'
        WillPaginate::Finders::ActiveRecord.enable!
      end
    end
    
    initializer "will_paginate.action_dispatch" do |app|
      if defined? ::ActionDispatch::ShowExceptions
        ActionDispatch::ShowExceptions.rescue_responses['WillPaginate::InvalidPage'] = :not_found
      end
    end
    
    initializer "will_paginate.action_view" do |app|
      require 'will_paginate/view_helpers/action_view'
      ActionView::Base.send(:include, WillPaginate::ViewHelpers::ActionView)
    end
  end
end
