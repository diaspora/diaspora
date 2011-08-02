require 'new_relic/transaction_sample'
require 'new_relic/transaction_sample/segment'
module NewRelic
  class TransactionSample
    class FakeSegment < Segment
      public :parent_segment=
    end
  end
end
