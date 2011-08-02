require File.dirname(__FILE__) + "/../spec_helper"
require 'ostruct'

include Server
include Commands

def mock_adapter(opts = {})
  opts[:libraries] ||= {'project' => [LibraryVersion.new('project', '1.0.0'), LibraryVersion.new('project', '1.0.1')]}
  opts[:document_root] ||= '/public'
  opts[:options] ||= {:single_library => false, :caching => false}
  opts[:server_options] ||= {}
  OpenStruct.new(opts)
end

def mock_request(path = '/')
  OpenStruct.new(:path => path)
end
