#   Copyright (c) 2009, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Note < StatusMessage
  xml_name :note
  xml_attr :raw_extension

  has_one :note_extension, :dependent => :destroy, :foreign_key => :post_id

  attr_accessible :note_extension, :full_text

  def full_text(opts = {})
    self.full_formatted_message(opts)
  end

  def raw_full_text
    self.raw_message + self.raw_extension
  end

  def raw_extension
    if self.note_extension
      self.note_extension.read_attribute(:text)
    else
      ''
    end
  end
  def raw_extension=(text)
    if self.note_extension
      self.note_extension.write_attribute(:text, text)
    end
  end

  def full_formatted_message(opts={})
    return self.raw_full_text unless self.raw_full_text

    format_text(self.raw_full_text, opts)
  end

  def formatted_extension(opts={})
    return self.raw_extension unless self.raw_extension

    format_text(self.raw_extension, opts)
  end

  def to_activity(opts={})
    author = opts[:author] || self.author #Use an already loaded author if passed in.
    <<-XML
  <entry>
    <title>#{x(self.formatted_message(:plain_text => true))}</title>
    <content>#{x(self.formatted_extension(:plain_text => true))}</content>
    <link rel="alternate" type="text/html" href="#{author.url}p/#{self.id}"/>
    <id>#{author.url}p/#{self.id}</id>
    <published>#{self.created_at.xmlschema}</published>
    <updated>#{self.updated_at.xmlschema}</updated>
    <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
    <activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type>
  </entry>
    XML
  end
end
