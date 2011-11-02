require 'oembed'
require 'uri'

OEmbed::Providers.register_all
OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery)
#
# SECURITY NOTICE! CROSS-SITE SCRIPTING!
# these endpoints may inject html code into our page
# note that 'trusted_endpoint_url' is the only information
# in OEmbed that we can trust. anything else may be spoofed!
SECURE_ENDPOINTS = [::OEmbed::Providers::Youtube.endpoint,
                    ::OEmbed::Providers::Flickr.endpoint,
                    'http://soundcloud.com/oembed',
                    'http://cubbi.es/oembed'
                   ]
ENDPOINT_HOSTS_STRING = SECURE_ENDPOINTS.map{|e| URI.parse(e.split('{')[0]).host}.to_s
