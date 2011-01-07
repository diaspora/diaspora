module Mongo
  def self.table_name_prefix
    "mongo_"
  end

  class Aspect < ActiveRecord::Base; end
  class AspectMembership < ActiveRecord::Base; end
  class Comment < ActiveRecord::Base; end
  class Contact < ActiveRecord::Base; end
  class Invitation < ActiveRecord::Base; end
  class Notification < ActiveRecord::Base; end
  class Person < ActiveRecord::Base; end
  #Photo?
  class Post < ActiveRecord::Base; end
  class PostVisibility < ActiveRecord::Base; end
  class Profile < ActiveRecord::Base; end
  class Request < ActiveRecord::Base; end
  class Service < ActiveRecord::Base; end
  #StatusMessage?
  class User < ActiveRecord::Base; end
end
