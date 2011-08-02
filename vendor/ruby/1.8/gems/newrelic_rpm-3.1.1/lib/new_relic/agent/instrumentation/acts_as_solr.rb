module NewRelic
  module Instrumentation
    module ActsAsSolrInstrumentation
      module ParserMethodsInstrumentation
        def parse_query_with_newrelic(*args)
          self.class.trace_execution_scoped(["SolrClient/ActsAsSolr/query"]) do
            t0 = Time.now
            begin
              parse_query_without_newrelic(*args)
            ensure
              NewRelic::Agent.instance.transaction_sampler.notice_nosql(args.first.inspect, (Time.now - t0).to_f) rescue nil
            end
          end
        end
      end
    end
  end
end

DependencyDetection.defer do
  depends_on do
    defined?(ActsAsSolr)
  end

  depends_on do
    defined?(ActsAsSolr::ParserMethods)
  end

  depends_on do
    defined?(ActsAsSolr::ClassMethods)
  end

  depends_on do
    defined?(ActsAsSolr::CommonMethods)
  end
  
  executes do
    NewRelic::Agent.logger.debug 'Installing ActsAsSolr instrumentation'
  end
  
  executes do
    ActsAsSolr::ParserMethods.module_eval do
      include NewRelic::Instrumentation::ActsAsSolrInstrumentation::ParserMethodsInstrumentation
      alias :parse_query_without_newrelic :parse_query
      alias :parse_query :parse_query_with_newrelic
    end
  end

  executes do
    ActsAsSolr::ClassMethods.module_eval do
      %w[find_by_solr find_id_by_solr multi_solr_search count_by_solr].each do |method|
        add_method_tracer method, 'SolrClient/ActsAsSolr/query'
      end
      add_method_tracer :rebuild_solr_index, 'SolrClient/ActsAsSolr/index'
    end
  end

  executes do
    ActsAsSolr::CommonMethods.module_eval do
      add_method_tracer :solr_add, 'SolrClient/ActsAsSolr/add'
      add_method_tracer :solr_delete, 'SolrClient/ActsAsSolr/delete'
      add_method_tracer :solr_commit, 'SolrClient/ActsAsSolr/commit'
      add_method_tracer :solr_optimize, 'SolrClient/ActsAsSolr/optimize'
    end
  end
end
