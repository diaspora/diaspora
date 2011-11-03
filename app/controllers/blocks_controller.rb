class BlocksController < ApplicationController
  before_filter :authenticate_user!

  def create
    block = current_user.blocks.new(params[:block])

    if block.save
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
end
