# frozen_string_literal: true

require "yalphabetize"

namespace :yalphabetize do
  task run: :environment do
    Yalphabetize::Yalphabetizer.call
  end
end
