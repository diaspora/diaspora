class Account < ActiveRecord::Base
  def self.authenticate(login, password)
    # N.B. Don't use this for authentication in a real app
    find_by_login_and_password(login, password)
  end
end