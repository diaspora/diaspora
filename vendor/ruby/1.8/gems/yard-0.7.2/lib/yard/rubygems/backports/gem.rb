module Gem
  ##
  # Returns the Gem::SourceIndex of specifications that are in the Gem.path

  def self.source_index
    @@source_index ||= SourceIndex.from_installed_gems
  end
end
