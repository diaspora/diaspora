require File.dirname(__FILE__) + '/lib/mobile_fu_helper.rb'
require File.dirname(__FILE__) + '/lib/mobilized_styles'
require File.dirname(__FILE__) + '/lib/mobile_fu'

ActionView::Base.send(:include, MobileFuHelper)
ActionView::Base.send(:include, MobilizedStyles)
ActionView::Base.send(:alias_method_chain, :stylesheet_link_tag, :mobilization)