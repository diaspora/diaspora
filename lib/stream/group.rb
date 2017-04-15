#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Stream::Group < Stream::Base
  def initialize(user, group_identifier, opts={})
    @group_identifier = group_identifier
    super(user, opts)
  end

  def group
    @group ||= Group.find_by_identifier(@group_identifier)
  end

  def posts
    group.posts
  end

  def publisher_opts
    {:prefill => "\n\n\n" + group.identifier_full, :open => true}
  end
end

