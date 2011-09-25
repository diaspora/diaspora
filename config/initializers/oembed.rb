require 'oembed'
OEmbed::Providers.register_all
OEmbed::Providers.register_fallback(OEmbed::ProviderDiscovery)

