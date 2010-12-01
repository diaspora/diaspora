module ActiveRecord
  # = Active Record Has Many Association
  module Associations
    # This is the proxy that handles a has many association.
    #
    # If the association has a <tt>:through</tt> option further specialization
    # is provided by its child HasManyThroughAssociation.
    class HasManyAssociation < AssociationCollection #:nodoc:
      def initialize(owner, reflection)
        @finder_sql = nil
        super
      end
      protected
        def owner_quoted_id
          if @reflection.options[:primary_key]
            quote_value(@owner.send(@reflection.options[:primary_key]))
          else
            @owner.quoted_id
          end
        end

        # Returns the number of records in this collection.
        #
        # If the association has a counter cache it gets that value. Otherwise
        # it will attempt to do a count via SQL, bounded to <tt>:limit</tt> if
        # there's one.  Some configuration options like :group make it impossible
        # to do an SQL count, in those cases the array count will be used.
        #
        # That does not depend on whether the collection has already been loaded
        # or not. The +size+ method is the one that takes the loaded flag into
        # account and delegates to +count_records+ if needed.
        #
        # If the collection is empty the target is set to an empty array and
        # the loaded flag is set to true as well.
        def count_records
          count = if has_cached_counter?
            @owner.send(:read_attribute, cached_counter_attribute_name)
          elsif @reflection.options[:counter_sql]
            @reflection.klass.count_by_sql(@counter_sql)
          else
            @reflection.klass.count(:conditions => @counter_sql, :include => @reflection.options[:include])
          end

          # If there's nothing in the database and @target has no new records
          # we are certain the current target is an empty array. This is a
          # documented side-effect of the method that may avoid an extra SELECT.
          @target ||= [] and loaded if count == 0

          if @reflection.options[:limit]
            count = [ @reflection.options[:limit], count ].min
          end

          return count
        end

        def has_cached_counter?
          @owner.attribute_present?(cached_counter_attribute_name)
        end

        def cached_counter_attribute_name
          "#{@reflection.name}_count"
        end

        def insert_record(record, force = false, validate = true)
          set_belongs_to_association_for(record)
          force ? record.save! : record.save(:validate => validate)
        end

        # Deletes the records according to the <tt>:dependent</tt> option.
        def delete_records(records)
          case @reflection.options[:dependent]
            when :destroy
              records.each { |r| r.destroy }
            when :delete_all
              @reflection.klass.delete(records.map { |record| record.id })
            else
              relation = Arel::Table.new(@reflection.table_name)
              relation.where(relation[@reflection.primary_key_name].eq(@owner.id).
                  and(relation[@reflection.klass.primary_key].in(records.map { |r| r.id }))
              ).update(relation[@reflection.primary_key_name] => nil)

              @owner.class.update_counters(@owner.id, cached_counter_attribute_name => -records.size) if has_cached_counter?
          end
        end

        def target_obsolete?
          false
        end

        def construct_sql
          case
            when @reflection.options[:finder_sql]
              @finder_sql = interpolate_sql(@reflection.options[:finder_sql])

            when @reflection.options[:as]
              @finder_sql =
                "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_id = #{owner_quoted_id} AND " +
                "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_type = #{@owner.class.quote_value(@owner.class.base_class.name.to_s)}"
              @finder_sql << " AND (#{conditions})" if conditions

            else
              @finder_sql = "#{@reflection.quoted_table_name}.#{@reflection.primary_key_name} = #{owner_quoted_id}"
              @finder_sql << " AND (#{conditions})" if conditions
          end

          construct_counter_sql
        end

        def construct_scope
          create_scoping = {}
          set_belongs_to_association_for(create_scoping)
          {
            :find => { :conditions => @finder_sql,
                       :readonly => false,
                       :order => @reflection.options[:order],
                       :limit => @reflection.options[:limit],
                       :include => @reflection.options[:include]},
            :create => create_scoping
          }
        end

        def we_can_set_the_inverse_on_this?(record)
          inverse = @reflection.inverse_of
          return !inverse.nil?
        end
    end
  end
end
