# frozen_string_literal: true

namespace :yalphabetize do
  task run: :environment do
    Yalphabetize::Yalphabetizer.call
  end
end
