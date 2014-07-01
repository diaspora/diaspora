class HelpController < ApplicationController
	before_filter -> { @css_framework = :bootstrap }
	layout ->(c) { request.format == :mobile ? "application" : "with_header_with_footer" }
end
