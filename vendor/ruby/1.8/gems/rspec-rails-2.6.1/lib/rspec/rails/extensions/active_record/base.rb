module RSpec
  module Rails
    if defined?(ActiveRecord)
      module Extensions
        module ActiveRecord
          # :call-seq:
          #   ModelClass.should have(:no).records
          #   ModelClass.should have(1).record
          #   ModelClass.should have(n).records
          #
          # Extension to enhance <tt>should have</tt> on AR Model classes
          def records
            find(:all)
          end
          alias :record :records
        end

        class ::ActiveRecord::Base #:nodoc:
          extend RSpec::Rails::Extensions::ActiveRecord
        end
      end
    end
  end
end

module ::ActiveModel::Validations
  # :call-seq:
  #   model.should have(:no).errors_on(:attribute)
  #   model.should have(1).error_on(:attribute)
  #   model.should have(n).errors_on(:attribute)
  #
  # Extension to enhance <tt>should have</tt> on AR Model instances.
  # Calls model.valid? in order to prepare the object's errors
  # object.
  def errors_on(attribute)
    self.valid?
    [self.errors[attribute]].flatten.compact
  end
  alias :error_on :errors_on
end
