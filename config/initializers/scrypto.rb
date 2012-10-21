Scrypto.owner_class = "Person"

def scrypto_id
  current_user.person.id
end
