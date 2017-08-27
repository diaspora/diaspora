# frozen_string_literal: true

require 'oembed'
require 'uri'

#
# SECURITY NOTICE! CROSS-SITE SCRIPTING!
# these endpoints may inject html code into our page
# note that 'trusted_endpoint_url' is the only information
# in OEmbed that we can trust. anything else may be spoofed!

oembed_provider_list = [
  OEmbed::Providers::Youtube,
  OEmbed::Providers::Vimeo,
  OEmbed::Providers::SoundCloud,
  OEmbed::Providers::Instagram,
  OEmbed::Providers::Flickr
]

oembed_providers = YAML.load_file(Rails.root.join("config", "oembed_providers.yml"))

oembed_providers.each do |provider_name, provider|
  oembed_provider = OEmbed::Provider.new(provider["endpoint"])
  provider["urls"].each do |provider_url|
    oembed_provider << provider_url
  end if provider["urls"]
  oembed_provider_list << oembed_provider
end

SECURE_ENDPOINTS = oembed_provider_list.map do |provider|
  OEmbed::Providers.register(provider)
  provider.endpoint
end

OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery)

TRUSTED_OEMBED_PROVIDERS = OEmbed::Providers
