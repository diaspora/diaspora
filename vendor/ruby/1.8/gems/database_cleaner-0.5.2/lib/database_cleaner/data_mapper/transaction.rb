module DatabaseCleaner::DataMapper
  class Transaction

    def start(repo = :default)
      DataMapper.repository(repo) do |r|
        transaction = DataMapper::Transaction.new(r)
        transaction.begin
        r.adapter.push_transaction(transaction)
      end
    end

    def clean(repo = :default)
      DataMapper.repository(repo) do |r|
        adapter = r.adapter
        while adapter.current_transaction
          adapter.current_transaction.rollback
          adapter.pop_transaction
        end
      end
    end

  end
end
