module DatabaseCleaner::ActiveRecord
  class Transaction

    def start
      if ActiveRecord::Base.connection.respond_to?(:increment_open_transactions)
        ActiveRecord::Base.connection.increment_open_transactions
      else
        ActiveRecord::Base.__send__(:increment_open_transactions)
      end

      ActiveRecord::Base.connection.begin_db_transaction
    end


    def clean
      ActiveRecord::Base.connection.rollback_db_transaction

      if ActiveRecord::Base.connection.respond_to?(:decrement_open_transactions)
        ActiveRecord::Base.connection.decrement_open_transactions
      else
        ActiveRecord::Base.__send__(:decrement_open_transactions)
      end
    end
  end

end
