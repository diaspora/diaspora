require 'oembed'
require 'uri'

OEmbedCubbies = OEmbed::Provider.new("http://cubbi.es/oembed")

OEmbed::Providers.register(
  OEmbed::Providers::Youtube,
  OEmbed::Providers::Vimeo,
  OEmbed::Providers::Flickr,
  OEmbed::Providers::SoundCloud,
  OEmbedCubbies
)
OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery)

#
# SECURITY NOTICE! CROSS-SITE SCRIPTING!
# these endpoints may inject html code into our page
# note that 'trusted_endpoint_url' is the only information
# in OEmbed that we can trust. anything else may be spoofed!
TRUSTED_OEMBED_PROVIDERS = OEmbed::Providers
