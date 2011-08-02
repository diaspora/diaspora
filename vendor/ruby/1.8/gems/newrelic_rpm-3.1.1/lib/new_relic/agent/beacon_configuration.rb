module NewRelic
  module Agent
    # This class contains the configuration data for setting up RUM
    # headers and footers - acts as a cache of this data so we don't
    # need to look it up or reconfigure it every request
    class BeaconConfiguration

      # the statically generated header - generated when the beacon
      # configuration is created - does not vary per page
      attr_reader :browser_timing_header

      # the static portion of the RUM footer - this part does not vary
      # by which request is in progress
      attr_reader :browser_timing_static_footer
      
      # the application id we include in the javascript -
      # crossreferences with the application id on the collectors
      attr_reader :application_id

      # the key used for browser monitoring. This is different from
      # the account key
      attr_reader :browser_monitoring_key

      # which beacon we should report to - set by startup of the agent
      attr_reader :beacon

      # whether RUM is enabled or not - determined based on server and
      # local config
      attr_reader :rum_enabled
      
      # A static javascript header that is identical for every account
      # and application
      JS_HEADER = "<script type=\"text/javascript\">var NREUMQ=[];NREUMQ.push([\"mark\",\"firstbyte\",new Date().getTime()]);</script>"
      
      # Creates a new browser configuration data. Argument is a hash
      # of configuration values from the server
      def initialize(connect_data)
        @browser_monitoring_key = connect_data['browser_key']
        @application_id = connect_data['application_id']
        @beacon = connect_data['beacon']
        @rum_enabled = connect_data['rum.enabled']
        @rum_enabled = true if @rum_enabled.nil?
        NewRelic::Control.instance.log.warn("Real User Monitoring is disabled for this agent. Edit your configuration to change this.") unless @rum_enabled
        @browser_timing_header = build_browser_timing_header
        NewRelic::Control.instance.log.debug("Browser timing header: #{@browser_timing_header.inspect}")
        @browser_timing_static_footer = build_load_file_js(connect_data)
        NewRelic::Control.instance.log.debug("Browser timing static footer: #{@browser_timing_static_footer.inspect}")
      end
      
      # returns a memoized version of the bytes in the license key for
      # obscuring transaction names in the javascript
      def license_bytes
        if @license_bytes.nil?
          @license_bytes = []
          NewRelic::Control.instance.license_key.each_byte {|byte| @license_bytes << byte}
        end
        @license_bytes
      end
      
      # returns a snippet of text that does not change
      # per-transaction. Is empty when rum is disabled, or we are not
      # including the episodes file dynamically (i.e. the user
      # includes it themselves)
      def build_load_file_js(connect_data)
        js = <<-EOS
if (!NREUMQ.f) NREUMQ.f=function() {
NREUMQ.push(["load",new Date().getTime()]);
EOS
    
        if connect_data.fetch('rum.load_episodes_file', true)
          episodes_url = connect_data.fetch('episodes_url', '')          
          js << <<-EOS
var e=document.createElement(\"script\");
e.type=\"text/javascript\";e.async=true;e.src=\"#{episodes_url}\";
document.body.appendChild(e);
EOS
        end
    
        js << <<-EOS
if(NREUMQ.a)NREUMQ.a();
};
if(window.onload!==NREUMQ.f){NREUMQ.a=window.onload;window.onload=NREUMQ.f;};
EOS
        js
      end

      # returns a copy of the static javascript header, in case people
      # are munging strings somewhere down the line
      def javascript_header
        JS_HEADER.dup
      end
      
      # Returns the header string, properly html-safed if needed
      def build_browser_timing_header
        return "" if !@rum_enabled
        return "" if @browser_monitoring_key.nil?
        
        value = javascript_header
        if value.respond_to?(:html_safe)
          value.html_safe
        else
          value
        end
      end
    end
  end
end


