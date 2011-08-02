require 'faraday'

class Faraday::Request
  autoload :OAuth,  'faraday/request/oauth'
  autoload :OAuth2, 'faraday/request/oauth2'
end

class Faraday::Response
  autoload :Mashify,      'faraday/response/mashify'
  autoload :ParseJson,    'faraday/response/parse_json'
  autoload :ParseMarshal, 'faraday/response/parse_marshal'
  autoload :ParseXml,     'faraday/response/parse_xml'
  autoload :ParseYaml,    'faraday/response/parse_yaml'
  autoload :Rashify,      'faraday/response/rashify'
end
