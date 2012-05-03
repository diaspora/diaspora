#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AnalyticsHelper
  def include_google_analytics
    return unless google_configured?

    segment = current_user ? current_user.role_name : "unauthenticated"
    javascript_tag do
      <<-JS
          var _gaq = _gaq || [];
          _gaq.push(['_setAccount', '#{AppConfig[:google_a_site]}']);

          _gaq.push(['_setCustomVar', 1, 'Role', '#{segment}']);
          _gaq.push(['_trackPageview']);
          _gaq.push(['_trackPageLoadTime']);

          (function() {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
          })();
      JS
    end
  end

  private

  def google_configured?
    AppConfig[:google_a_site].present? && AppConfig[:google_a_site].present?
  end
end