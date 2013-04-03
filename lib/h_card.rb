#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module HCard
  def self.parse doc
    {
      :given_name  => doc.css(".given_name").text,
      :family_name => doc.css(".family_name").text,
      :url         => doc.css("#pod_location").text,
      :photo       => doc.css(".entity_photo .photo[src]").attribute('src').text,
      :photo_small => doc.css(".entity_photo_small .photo[src]").attribute('src').text,
      :photo_medium => doc.css(".entity_photo_medium .photo[src]").attribute('src').text,
      :searchable  => doc.css(".searchable").text
    }
  end

  def self.build(raw_hcard)
    self.parse Nokogiri::HTML(raw_hcard)
  end
end
