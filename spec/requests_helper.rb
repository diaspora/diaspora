module RequestsHelper
  extend ActiveSupport::Concern
  include Warden::Test::Helpers

  def login(user)
    login_as user, scope: :user
  end

  included do
    after do
      Warden.test_reset!
    end
  end
end
