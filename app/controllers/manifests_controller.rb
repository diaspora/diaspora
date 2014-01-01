class ManifestsController < ApplicationController
  before_filter :authenticate_user!
  ALL_SCOPES = %w(profile_read 
                  contact_list_read 
                  post_write 
                  post_read 
                  post_delete 
                  comment_read 
                  comment_write)

  def index
    @manifests = current_user.manifests
  end

  def show
    @scopes = ALL_SCOPES
    @manifest = current_user.manifests.find(params[:id])
  end

  def new
    @scopes = ALL_SCOPES
    @manifest = Manifest.new
  end

  def create
    @scopes = ALL_SCOPES
    @manifest = Manifest.new(manifest_params)
    @manifest.dev = current_user
    if @manifest.save   
      render "show"
    else
      render "new"
      flash[:notice] = t("manifests.missing_values")
    end
  end

  def update
    @manifest = current_user.manifests.find(params[:id])
    @scopes = ALL_SCOPES
    if @manifest.update_attributes(manifest_params)
      redirect_to @manifest
      flash[:notice] = t("manifests.successfully_updated")
    else
      render action: "show"
    end
  end

  def destroy
    @manifest = current_user.manifests.find(params[:id])
    @manifest.destroy
    redirect_to manifests_url
  end

  def download
    manifest = current_user.manifests.find(params[:id])
    send_data manifest.create_manifest_json, :filename => "#{manifest.app_name}.json", :type => :json
  end

  private

  def manifest_params
    params.require(:manifest).permit(:app_description, :app_name, :app_version, :callback_url, :redirect_url, scopes: [])
  end
end
