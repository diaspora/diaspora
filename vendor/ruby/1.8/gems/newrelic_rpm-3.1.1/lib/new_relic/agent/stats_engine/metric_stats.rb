module NewRelic
  module Agent
    class StatsEngine
      # Handles methods related to actual Metric collection
      module MetricStats
        # A simple mutex-synchronized hash to make sure our statistics
        # are internally consistent even in truly-threaded rubies like JRuby
        class SynchronizedHash < Hash
          def initialize(*args)
            @mutex = Mutex.new
            super
          end

          def []=(*args)
            @mutex.synchronize {
              super
            }
          end

          def [](*args)
            @mutex.synchronize {
              super
            }
          end

          def clear(*args)
            @mutex.synchronize {
              super
            }
          end

          def delete(*args)
            @mutex.synchronize {
              super
            }
          end

          def delete_if(*args)
            @mutex.synchronize {
              super
            }
          end
        end
        
        # Returns all of the metric names of all the stats in the engine
        def metrics
          stats_hash.keys.map(&:to_s)
        end
        
        # a simple accessor for looking up a stat with no scope -
        # returns a new stats object if no stats object for that
        # metric exists yet
        def get_stats_no_scope(metric_name)
          stats_hash[NewRelic::MetricSpec.new(metric_name, '')] ||= NewRelic::MethodTraceStats.new
        end

        # This version allows a caller to pass a stat class to use
        def get_custom_stats(metric_name, stat_class)
          stats_hash[NewRelic::MetricSpec.new(metric_name)] ||= stat_class.new
        end

        # If use_scope is true, two chained metrics are created, one with scope and one without
        # If scoped_metric_only is true, only a scoped metric is created (used by rendering metrics which by definition are per controller only)
        def get_stats(metric_name, use_scope = true, scoped_metric_only = false, scope = nil)
          scope ||= scope_name if use_scope
          if scoped_metric_only
            spec = NewRelic::MetricSpec.new metric_name, scope
            stats = stats_hash[spec] ||= NewRelic::MethodTraceStats.new
          else
            stats = stats_hash[NewRelic::MetricSpec.new(metric_name)] ||= NewRelic::MethodTraceStats.new
            if scope && scope != metric_name
              spec = NewRelic::MetricSpec.new metric_name, scope
              stats = stats_hash[spec] ||= NewRelic::ScopedMethodTraceStats.new(stats)
            end
          end
          stats
        end
        
        # Returns a stat if one exists, otherwise returns nil. If you
        # want auto-initialization, use one of get_stats or get_stats_no_scope
        def lookup_stats(metric_name, scope_name = '')
          stats_hash[NewRelic::MetricSpec.new(metric_name, scope_name)]
        end
        
        # This module was extracted from the harvest method and should
        # be refactored
        module Harvest
          
          # merge data from previous harvests into this stats engine -
          # takes into account the case where there are new stats for
          # that metric, and the case where there is no current data
          # for that metric
          def merge_data(metric_data_hash)
            metric_data_hash.each do |metric_spec, metric_data|
              new_data = lookup_stats(metric_spec.name, metric_spec.scope)
              if new_data
                new_data.merge!(metric_data.stats)
              else
                stats_hash[metric_spec] = metric_data.stats
              end
            end
          end

          private
          def get_stats_hash_from(engine_or_hash)
            if engine_or_hash.is_a?(StatsEngine)
              engine_or_hash.stats_hash
            else
              engine_or_hash
            end
          end

          def coerce_to_metric_spec(metric_spec)
            if metric_spec.is_a?(NewRelic::MetricSpec)
              metric_spec
            else
              NewRelic::MetricSpec.new(metric_spec)
            end
          end

          def clone_and_reset_stats(metric_spec, stats)
            if stats.nil?
              raise "Nil stats for #{metric_spec.name} (#{metric_spec.scope})"
            end

            stats_copy = stats.clone
            stats.reset
            stats_copy
          end

          # if the previous timeslice data has not been reported (due to an error of some sort)
          # then we need to merge this timeslice with the previously accumulated - but not sent
          # data
          def merge_old_data!(metric_spec, stats, old_data)
            metric_data = old_data[metric_spec]
            stats.merge!(metric_data.stats) unless metric_data.nil?
          end

          def add_data_to_send_unless_empty(data, stats, metric_spec, id)
            # don't bother collecting and reporting stats that have
            # zero-values for this timeslice. significant
            # performance boost and storage savings.
            return if stats.is_reset?
            data[metric_spec] = NewRelic::MetricData.new((id ? nil : metric_spec), stats, id)
          end

          def merge_stats(other_engine_or_hash, metric_ids)
            old_data = get_stats_hash_from(other_engine_or_hash)

            timeslice_data = {}
            stats_hash.each do | metric_spec, stats |

              metric_spec = coerce_to_metric_spec(metric_spec)
              stats_copy = clone_and_reset_stats(metric_spec, stats)
              merge_old_data!(metric_spec, stats_copy, old_data)
              add_data_to_send_unless_empty(timeslice_data, stats_copy, metric_spec, metric_ids[metric_spec])
            end
            timeslice_data
          end

        end
        include Harvest

        # Harvest the timeslice data.  First recombine current statss
        # with any previously
        # unsent metrics, clear out stats cache, and return the current
        # stats.
        # ---
        # Note: this is not synchronized.  There is still some risk in this and
        # we will revisit later to see if we can make this more robust without
        # sacrificing efficiency.
        # +++
        def harvest_timeslice_data(previous_timeslice_data, metric_ids)

          poll harvest_samplers
          merge_stats(previous_timeslice_data, metric_ids)
        end

        # Remove all stats.  For test code only.
        def clear_stats
          @stats_hash = SynchronizedHash.new
          NewRelic::Agent::BusyCalculator.reset
        end

        # Reset each of the stats, such as when a new passenger instance starts up.
        def reset_stats
          stats_hash.values.each { |s| s.reset }
        end
        
        # returns a memoized SynchronizedHash that holds the actual
        # instances of Stats keyed off their MetricName
        def stats_hash
          @stats_hash ||= SynchronizedHash.new
        end
      end
    end
  end
end
