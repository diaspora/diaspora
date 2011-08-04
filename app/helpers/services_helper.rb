module ServicesHelper
  def contact_proxy(friend)
    friend.contact || Contact.new(:person => friend.person)
  end
end
