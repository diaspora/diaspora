require 'active_support/core_ext/object/blank'

module ActiveRecord
  module AttributeMethods
    module Dirty
      extend ActiveSupport::Concern
      include ActiveModel::Dirty
      include AttributeMethods::Write

      included do
        if self < ::ActiveRecord::Timestamp
          raise "You cannot include Dirty after Timestamp"
        end

        superclass_delegating_accessor :partial_updates
        self.partial_updates = true
      end

      # Attempts to +save+ the record and clears changed attributes if successful.
      def save(*) #:nodoc:
        if status = super
          @previously_changed = changes
          @changed_attributes.clear
        end
        status
      end

      # Attempts to <tt>save!</tt> the record and clears changed attributes if successful.
      def save!(*) #:nodoc:
        super.tap do
          @previously_changed = changes
          @changed_attributes.clear
        end
      end

      # <tt>reload</tt> the record and clears changed attributes.
      def reload(*) #:nodoc:
        super.tap do
          @previously_changed.clear
          @changed_attributes.clear
        end
      end

    private
      # Wrap write_attribute to remember original attribute value.
      def write_attribute(attr, value)
        attr = attr.to_s

        # The attribute already has an unsaved change.
        if attribute_changed?(attr)
          old = @changed_attributes[attr]
          @changed_attributes.delete(attr) unless field_changed?(attr, old, value)
        else
          old = clone_attribute_value(:read_attribute, attr)
          # Save Time objects as TimeWithZone if time_zone_aware_attributes == true
          old = old.in_time_zone if clone_with_time_zone_conversion_attribute?(attr, old)
          @changed_attributes[attr] = old if field_changed?(attr, old, value)
        end

        # Carry on.
        super(attr, value)
      end

      def update(*)
        if partial_updates?
          # Serialized attributes should always be written in case they've been
          # changed in place.
          super(changed | (attributes.keys & self.class.serialized_attributes.keys))
        else
          super
        end
      end

      def field_changed?(attr, old, value)
        if column = column_for_attribute(attr)
          if column.number? && column.null && (old.nil? || old == 0) && value.blank?
            # For nullable numeric columns, NULL gets stored in database for blank (i.e. '') values.
            # Hence we don't record it as a change if the value changes from nil to ''.
            # If an old value of 0 is set to '' we want this to get changed to nil as otherwise it'll
            # be typecast back to 0 (''.to_i => 0)
            value = nil
          else
            value = column.type_cast(value)
          end
        end

        old != value
      end

      def clone_with_time_zone_conversion_attribute?(attr, old)
        old.class.name == "Time" && time_zone_aware_attributes && !skip_time_zone_conversion_for_attributes.include?(attr.to_sym)
      end
    end
  end
end
