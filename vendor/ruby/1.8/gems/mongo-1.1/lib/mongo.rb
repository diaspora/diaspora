# encoding: UTF-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

module Mongo
  VERSION = "1.1"
end

module Mongo
  ASCENDING  =  1
  DESCENDING = -1
  GEO2D      = '2d'

  module Constants
    OP_REPLY        = 1
    OP_MSG          = 1000
    OP_UPDATE       = 2001
    OP_INSERT       = 2002
    OP_QUERY        = 2004
    OP_GET_MORE     = 2005
    OP_DELETE       = 2006
    OP_KILL_CURSORS = 2007

    OP_QUERY_TAILABLE          = 2 ** 1
    OP_QUERY_SLAVE_OK          = 2 ** 2
    OP_QUERY_OPLOG_REPLAY      = 2 ** 3
    OP_QUERY_NO_CURSOR_TIMEOUT = 2 ** 4
    OP_QUERY_AWAIT_DATA        = 2 ** 5
    OP_QUERY_EXHAUST           = 2 ** 6

    REPLY_CURSOR_NOT_FOUND     = 2 ** 0
    REPLY_QUERY_FAILURE        = 2 ** 1
    REPLY_SHARD_CONFIG_STALE   = 2 ** 2
    REPLY_AWAIT_CAPABLE        = 2 ** 3
  end
end

require 'bson'

require 'mongo/util/conversions'
require 'mongo/util/support'
require 'mongo/util/core_ext'
require 'mongo/util/server_version'

require 'mongo/collection'
require 'mongo/connection'
require 'mongo/cursor'
require 'mongo/db'
require 'mongo/exceptions'
require 'mongo/gridfs/grid_ext'
require 'mongo/gridfs/grid'
require 'mongo/gridfs/grid_io'
require 'mongo/gridfs/grid_file_system'
