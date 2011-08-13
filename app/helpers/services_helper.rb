module ServicesHelper
  def contact_proxy(friend)
    friend.contact || Contact.new(:person => friend.person, :aspects => [])
  end
end
