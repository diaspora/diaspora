# frozen_string_literal: true

module Workers
  class ImportProfile < Base
    sidekiq_options queue: :medium

    include Diaspora::Logging

    def perform(user_id)
      user = User.find_by(username: user_id)
      if user.nil?
        logger.error "A user with name #{user_id} is not a local user"
      else
        import_profile.import_by_user(user)
      end
    end

    private

    def import_profile
      @import_profile ||= ImportProfileService.new
    end
  end
end
