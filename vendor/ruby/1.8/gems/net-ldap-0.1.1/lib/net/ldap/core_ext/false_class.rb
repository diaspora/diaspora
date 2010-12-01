module Net
  class LDAP
    module Extensions
      module FalseClass
        def to_ber
          "\001\001\000"
        end
      end
    end
  end
end