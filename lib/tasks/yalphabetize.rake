# frozen_string_literal: true

namespace :yalphabetize do
  task :run do
    Yalphabetize::Yalphabetizer.call
  end
end
