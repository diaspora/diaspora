class Devise::PasswordsController < DeviseController
  layout "application", :only => [:new]
  before_filter -> { @css_framework = :bootstrap }, only: [:new]
end
