#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PeopleHelper
  include ERB::Util
  def request_partial single_aspect_form
    if single_aspect_form
      'requests/new_request_with_aspect_to_person'
    else
      'requests/new_request_to_person'
    end
  end

  def search_or_index
    if params[:q]
      I18n.t 'people.helper.results_for',:params => params[:q]
    else
      I18n.t "people.helper.people_on_pod_are_aware_of"
    end
  end

  def birthday_format(bday)
    if bday.year == 1000
      I18n.l bday, :format => I18n.t('date.formats.birthday')
    else
      I18n.l bday, :format => I18n.t('date.formats.birthday_with_year')
    end
  end

  def person_link(person, opts={})
    opts[:class] ||= ""
    opts[:class] << " self" if defined?(user_signed_in?) && user_signed_in? && current_user.person == person
    remote_or_hovercard_link = "/people/#{person.id}".html_safe
    "<a data-hovercard='#{remote_or_hovercard_link}' #{person_href(person)} class='#{opts[:class]}'>#{h(person.name)}</a>".html_safe
  end

  def person_image_tag(person, size=nil)
    size ||= :thumb_small
    "<img alt=\"#{h(person.name)}\" class=\"avatar\" data-person_id=\"#{person.id}\" src=\"#{person.profile.image_url(size)}\" title=\"#{h(person.name)} (#{h(person.diaspora_handle)})\">".html_safe
  end

  def person_image_link(person, opts={})
    return "" if person.nil? || person.profile.nil?
    if opts[:to] == :photos
      link_to person_image_tag(person, opts[:size]), person_photos_path(person)
    else
      "<a #{person_href(person)} class='#{opts[:class]}'>
      #{person_image_tag(person, opts[:size])}
      </a>".html_safe
    end
  end

  def person_href(person)
    if person.local?
      username = person.diaspora_handle.split('@')[0]
      unless username.include?('.')
        return "href='/u/#{person.diaspora_handle.split('@')[0]}'"
      end
    end
    return "href='/people/#{person.id}'"
  end

end
