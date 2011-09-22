#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# TODO: figure out why this isn't being auto-loaded
require File.dirname(__FILE__) + "/aspect_stream.rb"

class NoteStream < AspectStream
  def link(opts={})
    Rails.application.routes.url_helpers.notes_path(opts)
  end

  def title
    I18n.translate("streams.notes.title")
  end

  def contacts_title
    I18n.translate("streams.notes.contacts_title")
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= user.visible_posts(:all_aspects? => for_all_aspects?,
                                   :by_members_of => aspect_ids,
                                   :type => 'Note',
                                   :order => "#{order} DESC",
                                   :max_time => max_time
                   ).for_a_stream(max_time, order)
  end
end
