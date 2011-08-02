require "helper"

module Nokogiri
  module XML
    class Node
      class TestSaveOptions < Nokogiri::TestCase
        SaveOptions.constants.each do |constant|
          class_eval %{
            def test_predicate_#{constant.downcase}
              options = SaveOptions.new(SaveOptions::#{constant})
              assert options.#{constant.downcase}?

              assert SaveOptions.new.#{constant.downcase}.#{constant.downcase}?
            end
          }
        end
      end
    end
  end
end
