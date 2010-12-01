module Net
  class LDAP
    module Extensions
      module TrueClass
        def to_ber
          "\001\001\001"
        end
      end
    end
  end
end