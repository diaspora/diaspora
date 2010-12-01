#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Chef
  # == Chef::Exceptions
  # Chef's custom exceptions are all contained within the Chef::Exceptions
  # namespace.
  class Exceptions
    class Application < RuntimeError; end
    class Cron < RuntimeError; end
    class Env < RuntimeError; end
    class Exec < RuntimeError; end
    class FileNotFound < RuntimeError; end  
    class Package < RuntimeError; end
    class Service < RuntimeError; end
    class Route < RuntimeError; end
    class SearchIndex < RuntimeError; end  
    class Override < RuntimeError; end
    class UnsupportedAction < RuntimeError; end
    class MissingLibrary < RuntimeError; end
    class MissingRole < RuntimeError; end
    class CannotDetermineNodeName < RuntimeError; end
    class User < RuntimeError; end
    class Group < RuntimeError; end
    class Link < RuntimeError; end
    class Mount < RuntimeError; end
    class CouchDBNotFound < RuntimeError; end
    class PrivateKeyMissing < RuntimeError; end
    class CannotWritePrivateKey < RuntimeError; end
    class RoleNotFound < RuntimeError; end
    class ValidationFailed < ArgumentError; end
    class InvalidPrivateKey < ArgumentError; end
    class ConfigurationError < ArgumentError; end
    class RedirectLimitExceeded < RuntimeError; end
    class AmbiguousRunlistSpecification < ArgumentError; end
    class CookbookNotFound < RuntimeError; end
    class AttributeNotFound < RuntimeError; end
    class InvalidCommandOption < RuntimeError; end
    class CommandTimeout < RuntimeError; end
    class ShellCommandFailed < RuntimeError; end
    class RequestedUIDUnavailable < RuntimeError; end
    class InvalidHomeDirectory < ArgumentError; end
    class DsclCommandFailed < RuntimeError; end
    class UserIDNotFound < ArgumentError; end
    class GroupIDNotFound < ArgumentError; end
    class InvalidResourceReference < RuntimeError; end
    class ResourceNotFound < RuntimeError; end
    class InvalidResourceSpecification < ArgumentError; end
    class SolrConnectionError < RuntimeError; end
    class IllegalChecksumRevert < RuntimeError; end
  end
end
