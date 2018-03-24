
# frozen_string_literal: true

module Admin
  class PodsController < AdminController
    respond_to :html, :json, :mobile

    def index
      pods_json = PodPresenter.as_collection(Pod.all)

      respond_with do |format|
        format.html do
          gon.preloads[:pods] = pods_json
          gon.unchecked_count = Pod.unchecked.count
          gon.version_failed_count = Pod.version_failed.count
          gon.error_count = Pod.check_failed.count

          render "admins/pods"
        end
        format.mobile { render "admins/pods" }
        format.json { render json: pods_json }
      end
    end

    def recheck
      pod = Pod.find(params[:pod_id])
      pod.test_connection!

      respond_with do |format|
        format.html { redirect_to admin_pods_path }
        format.json { render json: PodPresenter.new(pod).as_json }
      end
    end
  end
end
