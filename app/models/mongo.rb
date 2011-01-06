module Mongo
  def self.table_name_prefix
    "mongo_"
  end

  class User < ActiveRecord::Base; end
  class Aspect < ActiveRecord::Base; end
  class AspectMembership < ActiveRecord::Base; end
  class Comment < ActiveRecord::Base; end
  class Contact < ActiveRecord::Base; end
end
