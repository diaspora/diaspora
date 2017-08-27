# frozen_string_literal: true

module UserApplicationsHelper
  def user_application_name(app)
    if app.name?
      "#{html_escape app.name} (#{link_to(app.url, app.url)})"
    else
      link_to(app.url, app.url)
    end
  end
end
