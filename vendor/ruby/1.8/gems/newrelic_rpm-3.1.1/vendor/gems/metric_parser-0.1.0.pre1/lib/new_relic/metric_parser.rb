module NewRelic
  # Metric parsing logic mixin.  Given a metric name (attribute called "name"), provide a set of accessors
  # that enable inspection of the metric.  A metric has 2 or more segments, each separated
  # by the '/' character.  The metric's category is specified by its first segment. Following
  # are the set of categories currently supported by NewRelic's default metric set:
  #
  # * Controller
  # * ActiveRecord
  # * Rails
  # * WebService
  # * View
  # * Database
  # * Custom
  #
  # Based on the category of the metric, specific parsing logic is defined in the source files
  # countained in the "metric_parsers" sub directory local to this file.
  #
  module MetricParser
  end
end

require 'new_relic/metric_parser/metric_parser'
require 'new_relic/metric_parser/apdex'

require 'new_relic/metric_parser/action_mailer'
require 'new_relic/metric_parser/active_merchant'
require 'new_relic/metric_parser/active_record'
require 'new_relic/metric_parser/apdex'
require 'new_relic/metric_parser/background_transaction'
require 'new_relic/metric_parser/client'
require 'new_relic/metric_parser/controller'
require 'new_relic/metric_parser/controller_cpu'
require 'new_relic/metric_parser/controller_ext'
require 'new_relic/metric_parser/database'
require 'new_relic/metric_parser/database_pool'
require 'new_relic/metric_parser/dot_net'
require 'new_relic/metric_parser/errors'
require 'new_relic/metric_parser/external'
require 'new_relic/metric_parser/frontend'
require 'new_relic/metric_parser/gc'
require 'new_relic/metric_parser/hibernate_session'
require 'new_relic/metric_parser/java'
require 'new_relic/metric_parser/java_parser'
require 'new_relic/metric_parser/jsp'
require 'new_relic/metric_parser/jsp_tag'
require 'new_relic/metric_parser/mem_cache'
require 'new_relic/metric_parser/metric_parser'
require 'new_relic/metric_parser/orm'
require 'new_relic/metric_parser/other_transaction'
require 'new_relic/metric_parser/servlet'
require 'new_relic/metric_parser/servlet_context_listener'
require 'new_relic/metric_parser/servlet_filter'
require 'new_relic/metric_parser/solr'
require 'new_relic/metric_parser/solr_request_handler'
require 'new_relic/metric_parser/spring'
require 'new_relic/metric_parser/spring_controller'
require 'new_relic/metric_parser/spring_view'
require 'new_relic/metric_parser/struts_action'
require 'new_relic/metric_parser/struts_result'
require 'new_relic/metric_parser/version'
require 'new_relic/metric_parser/view'
require 'new_relic/metric_parser/web_frontend'
require 'new_relic/metric_parser/web_service'
require 'new_relic/metric_parser/web_transaction'
