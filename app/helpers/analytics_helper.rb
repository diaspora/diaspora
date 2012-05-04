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

  def chartbeat_head_block
    return unless chartbeat_configured?
    javascript_tag("var _sf_startpt=(new Date()).getTime()")
  end

  def include_chartbeat
    return unless chartbeat_configured?
    javascript_tag do
      <<-JS
        var _sf_async_config = { uid: #{AppConfig[:chartbeat_uid]}, domain: '#{AppConfig[:pod_uri].host}' };
        (function() {
          function loadChartbeat() {
            window._sf_endpt = (new Date()).getTime();
            var e = document.createElement('script');
            e.setAttribute('language', 'javascript');
            e.setAttribute('type', 'text/javascript');
            e.setAttribute('src',
                           (('https:' == document.location.protocol) ? 'https://a248.e.akamai.net/chartbeat.download.akamai.com/102508/' : 'http://static.chartbeat.com/') +
                               'js/chartbeat.js');
            document.body.appendChild(e);
          };
          var oldonload = window.onload;
          window.onload = (typeof window.onload != 'function') ?
              loadChartbeat : function() { oldonload(); loadChartbeat(); };
        })();
      JS
    end
  end

  private

  def google_configured?
    AppConfig[:google_a_site].present? && AppConfig[:google_a_site].present?
  end

  def chartbeat_configured?
    AppConfig[:chartbeat_uid].present?
  end
end