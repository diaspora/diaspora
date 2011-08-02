module DatabaseCleaner
  module CouchPotato
    def self.available_strategies
      %w[truncation]
    end
  end
end
