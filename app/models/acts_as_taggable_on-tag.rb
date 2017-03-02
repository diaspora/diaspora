module ActsAsTaggableOn
  class Tag

    self.include_root_in_json = false

    def self.tag_text_regexp
      @@tag_text_regexp ||= "[[:word:]]\u{055b}\u{055c}\u{055e}\u{058a}_-"
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
