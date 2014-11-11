class PasswordsController < Devise::PasswordsController
  layout ->(c) { request.format == :mobile ? "application" : "with_header_with_footer" }
  before_filter -> { @css_framework = :bootstrap }
end
