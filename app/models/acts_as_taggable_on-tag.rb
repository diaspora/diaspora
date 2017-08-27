# frozen_string_literal: true

module ActsAsTaggableOn
  class Tag

    self.include_root_in_json = false

    def self.tag_text_regexp
      @tag_text_regexp ||= "[[:word:]]\u055b\u055c\u055e\u058a_-"
    end

    def self.autocomplete(name)
      where("name LIKE ?", "#{name.downcase}%").order("name ASC")
    end

    def self.normalize(name)
      if name =~ /^#?<3/
        # Special case for love, because the world needs more love.
        '<3'
      elsif name
        name.gsub(/[^#{self.tag_text_regexp}]/, '').downcase
      end
    end
  end
end
