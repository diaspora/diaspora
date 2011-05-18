#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Bookmark < Post
  include Diaspora::Socketable

  validates_presence_of :target_url


  def socket_to_user(user_or_id, opts={}) #adds aspect_ids to opts if they are not there
    unless opts[:aspect_ids]
      user_id = user_or_id.instance_of?(Fixnum) ? user_or_id : user_or_id.id
      aspect_ids = AspectMembership.connection.execute(
        AspectMembership.joins(:contact).where(:contacts => {:user_id => user_id, :person_id => self.author_id}).select('aspect_memberships.aspect_id').to_sql
      ).map{|r| r.first}
      opts.merge!(:aspect_ids => aspect_ids)
    end
    super(user_or_id, opts)
  end

  def self.from_activity(json)
    self.new(
      :image_url => json["target"]["image"]["url"],
      :image_height => json["target"]["image"]["height"],
      :image_width => json["target"]["image"]["width"],
      :target_url => json["target"]["url"]
    )
  end
end

