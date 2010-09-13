#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


module ErrorMessagesHelper
  # Render error messages for the given objects. The :message and :header_message options are allowed.
  def error_messages_for(*objects)
    options = objects.extract_options! 
    options[:header_message] ||= "Invalid Fields"
    options[:message] ||= "Correct the following errors and try again."
    messages = objects.compact.map { |o| o.errors.full_messages }.flatten
    unless messages.empty?
      content_tag(:div, :class => "error_messages") do
        list_items = messages.map { |msg| content_tag(:li, msg) }
        content_tag(:h2, options[:header_message]) + content_tag(:p, options[:message]) + content_tag(:ul, list_items.join.html_safe)
      end
    end
  end
  
  module FormBuilderAdditions
    def error_messages(options = {})
      @template.error_messages_for(@object, options)
    end
  end
end

ActionView::Helpers::FormBuilder.send(:include, ErrorMessagesHelper::FormBuilderAdditions)
