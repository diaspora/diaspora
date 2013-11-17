class BlocksController < ApplicationController
  before_action :authenticate_user!

  respond_to :html, :json

  def create
    block = current_user.blocks.new(block_params)

    if block.save
      disconnect_if_contact(block.person)
      notice = {:notice => t('blocks.create.success')}
    else
      notice = {:error => t('blocks.create.failure')}
    end

    respond_with do |format|
      format.html{ redirect_to :back, notice }
      format.json{ render :nothing => true, :status => 204 }
    end
  end

  def destroy
    if current_user.blocks.find(params[:id]).delete
      notice = {:notice => t('blocks.destroy.success')}
    else
      notice = {:error => t('blocks.destroy.failure')}
    end

    respond_with do |format|
      format.html{ redirect_to :back, notice }
      format.json{ render :nothing => true, :status => 204 }
    end
  end

  private

  def disconnect_if_contact(person)
    if contact = current_user.contact_for(person)
      current_user.disconnect(contact, :force => true)
    end
  end

  def block_params
    params.require(:block).permit(:person_id)
  end
end
