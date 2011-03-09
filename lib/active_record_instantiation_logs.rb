#This file ripped out of Oink at:
# github.com/noahd1/oink
# Thanks!
  require 'benchmark'
module Oink

  def self.extended_active_record?
    @oink_extended_active_record
  end

  def self.extended_active_record!
    @oink_extended_active_record = true
  end

  module InstanceTypeCounter
    def self.included(klass)
      ActiveRecord::Base.send(:include, OinkInstanceTypeCounterInstanceMethods)
    end

    def before_report_active_record_count(instantiation_data)
    end

    def report_hash!
      hash = self.report_hash
      ActiveRecord::Base.reset_instance_type_count
      hash
    end
    def report_hash
      hash = ActiveRecord::Base.instantiated_hash.merge(
        :total_ar_instances => ActiveRecord::Base.total_objects_instantiated,
        :ms_in_instantiate => ActiveRecord::Base.instantiation_time)
      before_report_active_record_count(hash)
      hash
    end

    def report_instance_type_count
      hash = self.hash
      hash[:event] = 'instantiation_breakdown'
      before_report_active_record_count(hash)
      if logger
        logger.info(hash)
      end
      ActiveRecord::Base.reset_instance_type_count
    end
  end

  module OinkInstanceTypeCounterInstanceMethods

    def self.included(klass)
      klass.class_eval do

        @@instantiated = {}
        @@total = nil
        @@time = 0.0

        def self.reset_instance_type_count
          @@time = 0.0
          @@instantiated = {}
          @@total = nil
        end

        def self.increment_instance_type_count(time)
          @@instantiated[base_class.name] ||= 0
          @@instantiated[base_class.name] += 1
          @@time += time
        end

        def self.instantiated_hash
          @@instantiated
        end

        def self.instantiation_time
          @@time
        end

        def self.total_objects_instantiated
          @@total ||= @@instantiated.values.sum
        end

        unless Oink.extended_active_record?
          class << self
            alias_method :instantiate_before_oink, :instantiate

            def instantiate(*args, &block)
              value = nil
              time = Benchmark.realtime{
                value = instantiate_before_oink(*args, &block)
              }*1000
              increment_instance_type_count(time)
              value
            end
          end

          alias_method :initialize_before_oink, :initialize

          def initialize(*args, &block)
            value = nil
            time = Benchmark.realtime{
              value = initialize_before_oink(*args, &block)
            }*1000
            self.class.increment_instance_type_count(time)
            value
          end

          Oink.extended_active_record!
        end
      end
    end
  end
end

