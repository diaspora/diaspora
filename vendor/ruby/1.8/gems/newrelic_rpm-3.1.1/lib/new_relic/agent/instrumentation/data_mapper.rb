## NewRelic instrumentation for DataMapper
#
# Instrumenting DM has different key challenges versus AR:
#
#   1. The hooking of SQL logging in DM is decoupled from any knowledge of the
#      Model#method that invoked it.  But on the positive side, the duration is
#      already calculated for you (and it happens inside the C-based DO code, so
#      it's faster than a Ruby equivalent).
#
#   2. There are a lot more entry points that need to be hooked in order to
#      understand call flow: DM::Model (model class) vs. DM::Resource (model
#      instance) vs. DM::Collection (collection of model instances).  And
#      others.
#
#   3. Strategic Eager Loading (SEL) combined with separately-grouped
#      lazy-loaded attributes presents a unique problem for tying resulting
#      SEL-invoked SQL calls to their proper scope.
#
# NOTE: On using "Database" versus "ActiveRecord" as base metric name
#
#   Using "Database" as the metric name base seems to properly identify methods
#   as being DB-related in call graphs, but certain New Relic views that show
#   aggregations of DB CPM, etc still seem to rely solely on "ActiveRecord"
#   being the base name, thus AFAICT "Database" calls to this are lost.  (Though
#   I haven't yet tested "Database/SQL/{find/save/destroy/all}" yet, as it seems
#   like an intuitively good name to use.)
#
#   So far I think these are the rules:
#
#     - ActiveRecord/{find/save/destroy} populates "Database Throughput" and
#       "Database Response Time" in the Database tab. [non-scoped]
#
#     - ActiveRecord/all populates the main Overview tab of DB time.  (still
#       unsure about this one). [non-scoped]
#
#     These metrics are represented as :push_scope => false or included as the
#     non-first metric in trace_execution_scoped() (docs say only first counts
#     towards scope) so they don't show up ine normal call graph/trace.

DependencyDetection.defer do
  depends_on do
    defined?(::DataMapper)
  end

  depends_on do
    defined?(DataMapper::Model)
  end

  depends_on do
    defined?(DataMapper::Resource)
  end

  depends_on do
    defined?(DataMapper::Collection)
  end
  
  executes do
    NewRelic::Agent.logger.debug 'Installing DataMapper instrumentation'
  end
  
  executes do
    DataMapper::Model.class_eval do
      add_method_tracer :get,      'ActiveRecord/#{self.name}/get'
      add_method_tracer :first,    'ActiveRecord/#{self.name}/first'
      add_method_tracer :last,     'ActiveRecord/#{self.name}/last'
      add_method_tracer :all,      'ActiveRecord/#{self.name}/all'

      add_method_tracer :create,   'ActiveRecord/#{self.name}/create'
      add_method_tracer :create!,  'ActiveRecord/#{self.name}/create'
      add_method_tracer :update,   'ActiveRecord/#{self.name}/update'
      add_method_tracer :update!,  'ActiveRecord/#{self.name}/update'
      add_method_tracer :destroy,  'ActiveRecord/#{self.name}/destroy'
      add_method_tracer :destroy!, 'ActiveRecord/#{self.name}/destroy'

      # For dm-aggregates and partial dm-ar-finders support:
      for method in [ :aggregate, :find, :find_by_sql ] do
        next unless method_defined? method
        add_method_tracer(method, 'ActiveRecord/#{self.name}/' + method.to_s)
      end

    end
  end

  executes do
    DataMapper::Resource.class_eval do
      add_method_tracer :update,   'ActiveRecord/#{self.class.name[/[^:]*$/]}/update'
      add_method_tracer :update!,  'ActiveRecord/#{self.class.name[/[^:]*$/]}/update'
      add_method_tracer :save,     'ActiveRecord/#{self.class.name[/[^:]*$/]}/save'
      add_method_tracer :save!,    'ActiveRecord/#{self.class.name[/[^:]*$/]}/save'
      add_method_tracer :destroy,  'ActiveRecord/#{self.class.name[/[^:]*$/]}/destroy'
      add_method_tracer :destroy!, 'ActiveRecord/#{self.class.name[/[^:]*$/]}/destroy'

    end
  end

  executes do
    DataMapper::Collection.class_eval do
      # DM's Collection instance methods
      add_method_tracer :get,       'ActiveRecord/#{self.name}/get'
      add_method_tracer :first,     'ActiveRecord/#{self.name}/first'
      add_method_tracer :last,      'ActiveRecord/#{self.name}/last'
      add_method_tracer :all,       'ActiveRecord/#{self.name}/all'

      add_method_tracer :lazy_load, 'ActiveRecord/#{self.name}/lazy_load'

      add_method_tracer :create,    'ActiveRecord/#{self.name}/create'
      add_method_tracer :create!,   'ActiveRecord/#{self.name}/create'
      add_method_tracer :update,    'ActiveRecord/#{self.name}/update'
      add_method_tracer :update!,   'ActiveRecord/#{self.name}/update'
      add_method_tracer :destroy,   'ActiveRecord/#{self.name}/destroy'
      add_method_tracer :destroy!,  'ActiveRecord/#{self.name}/destroy'

      # For dm-aggregates support:
      for method in [ :aggregate ] do
        next unless method_defined? method
        add_method_tracer(method, 'ActiveRecord/#{self.name}/' + method.to_s)
      end

    end
  end
end

DependencyDetection.defer do

  depends_on do
    defined?(DataMapper) && defined?(DataMapper::Adapters) && defined?(DataMapper::Adapters::DataObjectsAdapter)
  end

  executes do

    # Catch the two entry points into DM::Repository::Adapter that bypass CRUD
    # (for when SQL is run directly).
    DataMapper::Adapters::DataObjectsAdapter.class_eval do

      add_method_tracer :select,  'ActiveRecord/#{self.class.name[/[^:]*$/]}/select'
      add_method_tracer :execute, 'ActiveRecord/#{self.class.name[/[^:]*$/]}/execute'

    end
  end
end

DependencyDetection.defer do

  depends_on do
    defined?(DataMapper) && defined?(DataMapper::Validations) && defined?(DataMapper::Validations::ClassMethods)
  end

  # DM::Validations overrides Model#create, but currently in a way that makes it
  # impossible to instrument from one place.  I've got a patch pending inclusion
  # to make it instrumentable by putting the create method inside ClassMethods.
  # This will pick it up if/when that patch is accepted.
  executes do
    DataMapper::Validations::ClassMethods.class_eval do
      next unless method_defined? :create
      add_method_tracer :create,   'ActiveRecord/#{self.name}/create'
    end
  end
end

DependencyDetection.defer do

  depends_on do
    defined?(DataMapper) && defined?(DataMapper::Transaction)
  end

  # NOTE: DM::Transaction basically calls commit() twice, so as-is it will show
  # up in traces twice -- second time subordinate to the first's scope.  Works
  # well enough.
  executes do
    DataMapper::Transaction.module_eval do
      add_method_tracer :commit, 'ActiveRecord/#{self.class.name[/[^:]*$/]}/commit'
    end
  end
end


module NewRelic
  module Agent
    module Instrumentation
      module DataMapperInstrumentation

        def self.included(klass)
          klass.class_eval do
            alias_method :log_without_newrelic_instrumentation, :log
            alias_method :log, :log_with_newrelic_instrumentation
          end
        end

        # Unlike in AR, log is called in DM after the query actually ran,
        # complete with metrics.  Since DO has already calculated the
        # duration, there's nothing more to measure, so just record and log.
        #
        # We rely on the assumption that all possible entry points have been
        # hooked with tracers, ensuring that notice_sql attaches this SQL to
        # the proper call scope.
        def log_with_newrelic_instrumentation(msg)
          return unless NewRelic::Agent.is_execution_traced?
          return unless operation = case msg.query
                                    when /^\s*select/i          then 'find'
                                    when /^\s*(update|insert)/i then 'save'
                                    when /^\s*delete/i          then 'destroy'
                                    else nil
                                    end

          # FYI: self.to_s will yield connection URI string.
          duration = msg.duration / 1000000.0

          # Attach SQL to current segment/scope.
          NewRelic::Agent.instance.transaction_sampler.notice_sql(msg.query, nil, duration)

          # Record query duration associated with each of the desired metrics.
          metrics = [ "ActiveRecord/#{operation}", 'ActiveRecord/all' ]
          metrics.each do |metric|
            NewRelic::Agent.instance.stats_engine.get_stats_no_scope(metric).trace_call(duration)
          end
        ensure
          log_without_newrelic_instrumentation(msg)
        end

      end # DataMapperInstrumentation
    end # Instrumentation
  end # Agent
end # NewRelic

DependencyDetection.defer do

  depends_on do
    defined?(DataObjects) && defined?(DataObjects::Connection)
  end

  executes do
    DataObjects::Connection.class_eval do
      include ::NewRelic::Agent::Instrumentation::DataMapperInstrumentation
    end
  end
end
