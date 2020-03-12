# frozen_string_literal: true

class BlockService
  def initialize(user)
    @user = user
  end

  def block(person)
    raise ActiveRecord::RecordNotUnique if @user.blocks.exists?(person: person)

    block = @user.blocks.create!(person: person)
    contact = @user.contact_for(person)

    if contact
      @user.disconnect(contact)
    elsif block.person.remote?
      Diaspora::Federation::Dispatcher.defer_dispatch(@user, block)
    end
  end

  def unblock(person)
    remove_block(@user.blocks.find_by!(person: person))
  end

  def remove_block(block)
    block.destroy
    ContactRetraction.for(block).defer_dispatch(@user)
  end
end
