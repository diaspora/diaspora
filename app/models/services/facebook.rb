require 'uri'
class Services::Facebook < Service
  include Rails.application.routes.url_helpers

  MAX_CHARACTERS = 420

  def provider
    "facebook"
  end

  def post(post, url='')
    Rails.logger.debug("event=post_to_service type=facebook sender_id=#{self.user_id}")
    if post.public?
      post_to_facebook("https://graph.facebook.com/me/joindiaspora:make", create_open_graph_params(post).to_param)
    else
      post_to_facebook("https://graph.facebook.com/me/feed", create_post_params(post).to_param)
    end
  end

  def post_to_facebook(url, body)
    Faraday.post(url, body)
  end

  def create_open_graph_params(post)
    {:post => "#{AppConfig[:pod_url]}#{short_post_path(post)}", :access_token => self.access_token}
  end

  def create_post_params(post)
    message = post.text(:plain_text => true)
    {:message => message, :access_token => self.access_token, :link => URI.extract(message, ['https', 'http']).first}
  end

  def public_message(post, url)
    super(post, MAX_CHARACTERS, url)
  end

  def finder(opts = {})
    Rails.logger.debug("event=friend_finder type=facebook sender_id=#{self.user_id}")
    prevent_service_users_from_being_empty
    result = if opts[:local]
               self.service_users.with_local_people
             elsif opts[:remote]
               self.service_users.with_remote_people
             else
               self.service_users
             end
    result.includes(:contact => :aspects, :person => :profile).order('service_users.person_id DESC, service_users.name')
  end

  def save_friends
    url = "https://graph.facebook.com/me/friends?fields[]=name&fields[]=picture&access_token=#{URI.escape(self.access_token)}"
    response = Faraday.get(url)
    data = JSON.parse(response.body)['data']
    return unless data
    data.map!{ |p|
      su = ServiceUser.new(:service_id => self.id, :uid => p["id"], :photo_url => p["picture"], :name => p["name"], :username => p["username"])
      su.attach_local_models
      su
    }


    if postgres?
      # Take the naive approach to inserting our new visibilities for now.
      data.each do |su|
        if existing = ServiceUser.find_by_uid(su.uid)
          update_hash = OVERRIDE_FIELDS_ON_FB_UPDATE.inject({}) do |acc, element|
            acc[element] = su.send(element)
            acc
          end

          existing.update_attributes(update_hash)
        else
          su.save
        end
      end
    else
      ServiceUser.import(data, :on_duplicate_key_update => OVERRIDE_FIELDS_ON_FB_UPDATE + [:updated_at])
    end
  end
  
  def profile_photo_url
    "https://graph.facebook.com/#{self.uid}/picture?type=large&access_token=#{URI.escape(self.access_token)}"
  end
  
  private

  OVERRIDE_FIELDS_ON_FB_UPDATE = [:contact_id, :person_id, :request_id, :invitation_id, :photo_url, :name, :username]

  def prevent_service_users_from_being_empty
    Resque.enqueue(Jobs::UpdateServiceUsers, self.id)
  end
end
