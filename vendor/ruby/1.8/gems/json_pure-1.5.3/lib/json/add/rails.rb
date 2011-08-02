# This file used to implementations of rails custom objects for
# serialisation/deserialisation and is obsoleted now.

unless defined?(::JSON::JSON_LOADED) and ::JSON::JSON_LOADED
  require 'json'
end

$DEBUG and warn "required json/add/rails which is obsolete now!"
