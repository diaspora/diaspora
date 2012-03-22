require 'oembed'
require 'uri'

#
# SECURITY NOTICE! CROSS-SITE SCRIPTING!
# these endpoints may inject html code into our page
# note that 'trusted_endpoint_url' is the only information
# in OEmbed that we can trust. anything else may be spoofed!

OEmbedCubbies = OEmbed::Provider.new("http://cubbi.es/oembed")

oembed_provider_list = [
  OEmbed::Providers::Youtube,
  OEmbed::Providers::Vimeo,
  OEmbed::Providers::Flickr,
  OEmbed::Providers::SoundCloud,
  OEmbedCubbies
]

SECURE_ENDPOINTS = oembed_provider_list.map do |provider|
  OEmbed::Providers.register(provider)
  provider.endpoint
end

OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery)

TRUSTED_OEMBED_PROVIDERS = OEmbed::Providers
