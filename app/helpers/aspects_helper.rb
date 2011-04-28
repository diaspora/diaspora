#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectsHelper
  def next_page_path
    aspects_path(:max_time => @posts.last.send(session[:sort_order].to_sym).to_i, :a_ids => params[:a_ids], :class => 'paginate')
  end

  def remove_link(aspect)
    if aspect.contacts.size == 0
      link_to I18n.t('aspects.helper.remove'), aspect, :method => :delete, :confirm => I18n.t('aspects.helper.are_you_sure')
    else
      "<span class='grey' title=#{I18n.t('aspects.helper.aspect_not_empty')}>#{I18n.t('aspects.helper.remove')}</span>"
    end
  end

  def new_request_link(request_count)
    if request_count > 0
        link_to t('requests.helper.new_requests', :count => @request_count), manage_aspects_path
    end
  end
end
