require 'fileutils'

module Culerity
  module PersistentDelivery
 
    DELIVERIES_PATH =
      File.join(RAILS_ROOT, 'tmp', 'action_mailer_acceptance_deliveries.cache')
    
    def self.included(base)
      base.class_eval do
        def self.deliveries
          return [] unless File.exist?(DELIVERIES_PATH)
          File.open(DELIVERIES_PATH,'r') do |f| 
            Marshal.load(f)
          end
        end 
      
        def self.clear_deliveries
          FileUtils.rm_f DELIVERIES_PATH
        end
      end
    end
 
    def perform_delivery_persistent(mail)
      deliveries << mail
      File.open(DELIVERIES_PATH,'w') do |f| 
        f << Marshal.dump(deliveries)
      end 
    end 
 
  end
end

ActionMailer::Base.send :include, Culerity::PersistentDelivery if defined?(ActionMailer)

