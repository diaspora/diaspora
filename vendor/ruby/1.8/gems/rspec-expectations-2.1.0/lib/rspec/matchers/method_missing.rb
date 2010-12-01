module RSpec
  module Matchers
    def method_missing(sym, *args, &block) # :nodoc:
      return Matchers::BePredicate.new(sym, *args, &block) if sym.to_s =~ /^be_/
      return Matchers::Has.new(sym, *args, &block) if sym.to_s =~ /^have_/
      super
    end
  end
end
