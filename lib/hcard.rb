#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module HCard
  def self.fetch url
    Nokogiri::HTML(Net::HTTP.get URI.parse(url))
  end

  def self.parse doc
    {:given_name => doc.css(".given_name").text,
    :family_name => doc.css(".family_name").text,
    :url => doc.css("#pod_location").text,
    :photo => doc.css(".photo[src]").text}
  end

  def self.find url
    self.parse self.fetch(url)
  end
end
