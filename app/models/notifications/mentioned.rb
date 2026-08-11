# frozen_string_literal: true

module Notifications
  module Mentioned
    extend ActiveSupport::Concern

    def linked_object
      target.mentions_container
    end
  end
end
