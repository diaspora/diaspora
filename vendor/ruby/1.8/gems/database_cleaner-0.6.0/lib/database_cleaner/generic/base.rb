module ::DatabaseCleaner
   module Generic
     module Base

       def self.included(base)
         base.extend(ClassMethods)
         base.send(:include, InstanceMethods)
       end

       module InstanceMethods
         def db
           :default
         end
       end

       module ClassMethods
         def available_strategies
           %W[]
         end
       end
     end
   end
end
