module ActionDispatch::Routing
  class Mapper
    protected
      def devise_invitation(mapping, controllers)
        resource :invitation, :only => [:new, :create, :update], :path => mapping.path_names[:invitation], :controller => controllers[:invitations] do
          get :edit, :path => mapping.path_names[:accept], :as => :accept
        end
      end
  end
end
