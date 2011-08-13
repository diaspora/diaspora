module ServicesHelper
  @@contact_proxy = Contact.new(:aspects => [])
  def contact_proxy(friend)
    friend.contact || @@contact_proxy.dup.tap{|c| c.person = friend.person}
  end
end
