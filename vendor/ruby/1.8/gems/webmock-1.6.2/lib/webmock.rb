require 'singleton'

require 'addressable/uri'
require 'crack'

require 'webmock/deprecation'

require 'webmock/http_lib_adapters/net_http'
require 'webmock/http_lib_adapters/httpclient'
require 'webmock/http_lib_adapters/patron'
require 'webmock/http_lib_adapters/curb'
require 'webmock/http_lib_adapters/em_http_request'

require 'webmock/errors'

require 'webmock/util/uri'
require 'webmock/util/headers'
require 'webmock/util/hash_counter'
require 'webmock/util/hash_keys_stringifier'

require 'webmock/request_pattern'
require 'webmock/request_signature'
require 'webmock/responses_sequence'
require 'webmock/request_stub'
require 'webmock/response'

require 'webmock/stub_request_snippet'

require 'webmock/assertion_failure'
require 'webmock/request_execution_verifier'
require 'webmock/config'
require 'webmock/callback_registry'
require 'webmock/request_registry'
require 'webmock/stub_registry'
require 'webmock/api'
require 'webmock/webmock'