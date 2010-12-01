require 'will_paginate/view_helpers/base'
require 'will_paginate/view_helpers/link_renderer'

WillPaginate::ViewHelpers::LinkRenderer.class_eval do
  protected

  def url(page)
    params = @template.request.params.except(:action, :controller).merge(param_name => page)
    @template.url(:this, params)
  end
end

Merb::AbstractController.send(:include, WillPaginate::ViewHelpers::Base)