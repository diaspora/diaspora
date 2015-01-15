class HelpController < ApplicationController
  before_action -> { @css_framework = :bootstrap }
  layout ->(_c) { request.format == :mobile ? 'application' : 'with_header_with_footer' }
end
