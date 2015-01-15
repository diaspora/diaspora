class PasswordsController < Devise::PasswordsController
  layout 'application', only: [:new]
  before_action -> { @css_framework = :bootstrap }, only: [:new, :create, :edit]
end
