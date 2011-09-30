#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ActivityStreams::Photo < Post
  include Diaspora::Socketable

  xml_name self.name.underscore.gsub!('/', '-')
  xml_attr :image_url
  xml_attr :image_height
  xml_attr :image_width
  xml_attr :object_url
  xml_attr :actor_url
  xml_attr :objectId

  validates_presence_of :image_url,
                        :object_url,
                        :provider_display_name,
                        :actor_url,
                        :objectId

  # This wrapper around {Diaspora::Socketable#socket_to_user} adds aspect_ids to opts if they are not there.
  def socket_to_user(user_or_id, opts={})
    unless opts[:aspect_ids]
      user_id = user_or_id.instance_of?(Fixnum) ? user_or_id : user_or_id.id
      aspect_ids = AspectMembership.connection.select_values(
        AspectMembership.joins(:contact).where(:contacts => {:user_id => user_id, :person_id => self.author_id}).select('aspect_memberships.aspect_id').to_sql
      )
      opts.merge!(:aspect_ids => aspect_ids)
    end
    super(user_or_id, opts)
  end

  # This creates a new ActivityStreams::Photo from a json hash.
  # Right now, it is only used by Cubbi.es, but there will be objects for all the AS types.
  # @param [Hash] json An {http://www.activitystrea.ms ActivityStreams} compliant (we hope!) json hash.
  # @return [ActivityStreams::Photo]
  def self.from_activity(json)
    self.new(
      :image_url => json["object"]["image"]["url"],
      :image_height => json["object"]["image"]["height"],
      :image_width => json["object"]["image"]["width"],
      :object_url => json["object"]["url"],
      :objectId => json["object"]["id"],

      :provider_display_name => json["provider"]["displayName"],
      :actor_url => json["actor"]["url"]
    )
  end

  # A hack used in the stream_element partial to display cubbi.es posts correctly.
  # A better solution is needed.
  # @return [Boolean] true
  def activity_streams?; true; end

  def comment_email_subject
    I18n.t("photos.comment_email_subject", :name => author.name)
  end
end

