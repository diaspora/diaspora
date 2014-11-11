class PasswordsController < Devise::PasswordsController
  layout ->(c) { request.format == :mobile ? "application" : "with_header_with_footer" }, :only => [:new, :edit]
  before_filter -> { @css_framework = :bootstrap }, only: [:new, :create, :edit]
end
