class BlocksController < ApplicationController
  before_filter :authenticate_user!

  def create
    block = current_user.blocks.new(params[:block])

    if block.save
      disconnect_if_contact(block.person)
      notice = {:notice => t('blocks.create.success')}
    else
      notice = {:error => t('blocks.create.failure')}
    end
    redirect_to :back, notice
  end

  def destroy
    if current_user.blocks.find(params[:id]).delete
      notice = {:notice => t('blocks.destroy.success')}
    else
      notice = {:error => t('blocks.destroy.failure')}
    end
    redirect_to :back, notice
  end

  protected

  def disconnect_if_contact(person)
    if contact = current_user.contact_for(person)
      current_user.disconnect(contact, :force => true)
    end
  end
end
