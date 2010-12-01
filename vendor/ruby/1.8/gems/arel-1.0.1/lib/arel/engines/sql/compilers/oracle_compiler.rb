module Arel
  module SqlCompiler
    class OracleCompiler < GenericCompiler

      def select_sql
        select_clauses = relation.select_clauses
        from_clauses = relation.from_clauses
        joins = relation.joins(self)
        where_clauses = relation.where_clauses
        order_clauses = relation.order_clauses
        group_clauses = relation.group_clauses
        having_clauses = relation.having_clauses
        taken = relation.taken
        skipped = relation.skipped
        if limit_or_offset = !taken.blank? || !skipped.blank?
          # if need to select first records without ORDER BY and GROUP BY and without DISTINCT
          # then can use simple ROWNUM in WHERE clause
          if skipped.blank? && group_clauses.blank? && order_clauses.blank? && select_clauses[0] !~ /^DISTINCT /
            where_clauses << "ROWNUM <= #{taken}" if !taken.blank? && skipped.blank? && group_clauses.blank? && order_clauses.blank?
            limit_or_offset = false
          end
        end

        # when limit or offset subquery is used then cannot use FOR UPDATE directly
        # and need to construct separate subquery for primary key
        if use_subquery_for_lock = limit_or_offset && !locked.blank?
          quoted_primary_key = engine.connection.quote_column_name(relation.primary_key)
        end
        select_attributes_string = use_subquery_for_lock ? quoted_primary_key : select_clauses.join(', ')

        # OracleEnhanced adapter workaround when ORDER BY is used with columns not
        # present in DISTINCT columns list
        order_clauses_array = if select_attributes_string =~ /DISTINCT.*FIRST_VALUE/ && !order_clauses.blank?
          order = order_clauses.join(', ').split(',').map { |s| s.strip }.reject(&:blank?)
          order = order.zip((0...order.size).to_a).map { |s,i| "alias_#{i}__ #{'DESC' if s =~ /\bdesc$/i}" }
        else
          order_clauses
        end

        query = build_query \
          "SELECT     #{select_attributes_string}",
          "FROM       #{from_clauses}",
          (joins                                         unless joins.blank?               ),
          ("WHERE     #{where_clauses.join(' AND ')}"    unless where_clauses.blank?       ),
          ("GROUP BY  #{group_clauses.join(', ')}"       unless group_clauses.blank?       ),
          ("HAVING    #{having_clauses.join(' AND ')}"   unless having_clauses.blank?      ),
          ("ORDER BY  #{order_clauses_array.join(', ')}" unless order_clauses_array.blank? )

        # Use existing method from oracle_enhanced adapter to implement limit and offset using subqueries
        engine.connection.add_limit_offset!(query, :limit => taken, :offset => skipped) if limit_or_offset

        if use_subquery_for_lock
          build_query \
            "SELECT     #{select_clauses.join(', ')}",
            "FROM       #{from_clauses}",
            "WHERE      #{quoted_primary_key} IN (#{query})",
            "#{locked}"
        elsif !locked.blank?
          build_query query, "#{locked}"
        else
          query
        end
      end

      def delete_sql
        where_clauses = relation.wheres.collect(&:to_sql)
        taken = relation.taken
        where_clauses << "ROWNUM <= #{taken}" unless taken.blank?
        build_query \
          "DELETE",
          "FROM #{relation.table_sql}",
          ("WHERE #{where_clauses.join(' AND ')}" unless where_clauses.blank? )
      end

    protected

      def build_update_conditions_sql
        conditions = ""
        where_clauses = relation.wheres.collect(&:to_sql)
        taken = relation.taken
        # if need to select first records without ORDER BY
        # then can use simple ROWNUM in WHERE clause
        if !taken.blank? && relation.orders.blank?
          where_clauses << "ROWNUM <= #{taken}"
        end
        conditions << " WHERE #{where_clauses.join(' AND ')}" unless where_clauses.blank?
        unless taken.blank?
          conditions = limited_update_conditions(conditions, taken)
        end
        conditions
      end

      def limited_update_conditions(conditions, taken)
        order_clauses = relation.order_clauses
        # need to add ORDER BY only if just taken ones should be updated
        conditions << " ORDER BY #{order_clauses.join(', ')}" unless order_clauses.blank?
        quoted_primary_key = engine.connection.quote_column_name(relation.primary_key)
        subquery = "SELECT #{quoted_primary_key} FROM #{engine.connection.quote_table_name relation.table.name} #{conditions}"
        # Use existing method from oracle_enhanced adapter to get taken records when ORDER BY is used
        engine.connection.add_limit_offset!(subquery, :limit => taken) unless order_clauses.blank?
        "WHERE #{quoted_primary_key} IN (#{subquery})"
      end

    end
  end
end
