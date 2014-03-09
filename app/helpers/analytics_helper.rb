#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AnalyticsHelper
  def include_mixpanel
    include_analytics "mixpanel" do
      javascript_tag do
        <<-JS.html_safe
          (function(d,c){var a,b,g,e;a=d.createElement('script');a.type='text/javascript';a.async=!0;a.src=('https:'===d.location.protocol?'https:':'http:')+'//api.mixpanel.com/site_media/js/api/mixpanel.2.js';b=d.getElementsByTagName('script')[0];b.parentNode.insertBefore(a,b);c._i=[];c.init=function(a,d,f){var b=c;'undefined'!==typeof f?b=c[f]=[]:f='mixpanel';g='disable track track_pageview track_links track_forms register register_once unregister identify name_tag set_config'.split(' ');
          for(e=0;e<g.length;e++)(function(a){b[a]=function(){b.push([a].concat(Array.prototype.slice.call(arguments,0)))}})(g[e]);c._i.push([a,d,f])};window.mixpanel=c})(document,[]);
          mixpanel.init("#{AppConfig.privacy.mixpanel_uid}");
        JS
      end
    end
  end

  def include_mixpanel_guid
    return unless current_user
    include_analytics "mixpanel" do
      javascript_tag do
        <<-JS.html_safe
          mixpanel.name_tag("#{current_user.guid}");
        JS
      end
    end
  end

  def chartbeat_head_block
    return unless configured?("chartbeat")
    javascript_tag("var _sf_startpt=(new Date()).getTime()")
  end

  def include_chartbeat
    include_analytics "chartbeat" do
      javascript_tag do
        <<-JS.html_safe
          var _sf_async_config = { uid: #{AppConfig.privacy.chartbeat_uid}, domain: "#{AppConfig.pod_uri.host}" };
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
  end

  private

  def include_analytics(service, &block)
    return unless configured?(service)
    yield block
  end

  def configured?(service)
    AppConfig.privacy.send("#{service}_uid").present?
  end
end
