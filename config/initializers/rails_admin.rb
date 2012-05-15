# RailsAdmin config file. Generated on March 24, 2012 15:34
# See github.com/sferik/rails_admin for more informations
if Rails.env.production?
# Recommended way to deal with Kaminari vs. WillPaginate issues
if defined?(WillPaginate)
  Kaminari.configure do |config|
    config.page_method_name = :per_page_kaminari
  end
end
RailsAdmin.config do |config|
   config.authorize_with do 
    redirect_to main_app.root_path unless current_user.try(:admin?)
  end

  # If your default_local is different from :en, uncomment the following 2 lines and set your default locale here:
  # require 'i18n'
  # I18n.default_locale = :de

  config.current_user_method { current_user } # auto-generated

  # If you want to track changes on your models:
  # config.audit_with :history, User

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, User

  # Set the admin name here (optional second array element will appear in a beautiful RailsAdmin red ©)
  config.main_app_name = ['Diaspora', 'Admin']
  # or for a dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }


  #  ==> Global show view settings
  # Display empty fields in show views
  # config.compact_show_view = false

  #  ==> Global list view settings
  # Number of default rows per-page:
  # config.default_items_per_page = 20

  #  ==> Included models
  # Add all excluded models here:
  config.excluded_models = [ActivityStreams::Photo, AspectMembership, AspectVisibility, ShareVisibility, ConversationVisibility,  NotificationActor, Notifications::AlsoCommented, Notifications::CommentOnPost, Notifications::Liked, Notifications::Mentioned, Notifications::PrivateMessage, Notifications::RequestAccepted, Notifications::Reshared, Notifications::StartedSharing, Reshare, Services::Facebook, Services::Tumblr, Services::Twitter,  UserPreference]

  # Add models here if you want to go 'whitelist mode':
  # config.included_models = [AccountDeletion, ActivityStreams::Photo, ActsAsTaggableOn::Tag, Aspect, AspectMembership, AspectVisibility, Block, Comment, Contact, Conversation, ConversationVisibility, Invitation, InvitationCode, Like, Mention, Message, Notification, NotificationActor, Notifications::AlsoCommented, Notifications::CommentOnPost, Notifications::Liked, Notifications::Mentioned, Notifications::PrivateMessage, Notifications::RequestAccepted, Notifications::Reshared, Notifications::StartedSharing, OEmbedCache, Participation, Person, Photo, Pod, Post, Profile, Reshare, Service, ServiceUser, Services::Facebook, Services::Tumblr, Services::Twitter, ShareVisibility, StatusMessage, TagFollowing, User, UserPreference]

  # Application wide tried label methods for models' instances
  # config.label_methods << :description # Default is [:name, :title]

  #  ==> Global models configuration
  # config.models do
  #   # Configuration here will affect all included models in all scopes, handle with care!
  #
  #   list do
  #     # Configuration here will affect all included models in list sections (same for show, export, edit, update, create)
  #
  #     fields_of_type :date do
  #       # Configuration here will affect all date fields, in the list section, for all included models. See README for a comprehensive type list.
  #     end
  #   end
  # end
  #
  #  ==> Model specific configuration
  # Keep in mind that *all* configuration blocks are optional.
  # RailsAdmin will try his best to provide the best defaults for each section, for each field.
  # Try to override as few things as possible, in the most generic way. Try to avoid setting labels for models and attributes, use ActiveRecord I18n API instead.
  # Less code is better code!
  # config.model MyModel do
  #   # Cross-section field configuration
  #   object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #   label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #   label_plural 'My models'      # Same, plural
  #   weight -1                     # Navigation priority. Bigger is higher.
  #   parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #   navigation_label              # Sets dropdown entry's name in navigation. Only for parents!
  #   # Section specific configuration:
  #   list do
  #     filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #     items_per_page 100    # Override default_items_per_page
  #     sort_by :id           # Sort column (default is primary key)
  #     sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     # Here goes the fields configuration for the list view
  #   end
  # end

  # Your model's configuration, to help you get started:

  # All fields marked as 'hidden' won't be shown anywhere in the rails_admin unless you mark them as visible. (visible(true))

  # config.model AccountDeletion do
  #   # Found associations:
  #     configure :person, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :diaspora_handle, :string 
  #     configure :person_id, :integer         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model ActivityStreams::Photo do
  #   # Found associations:
  #     configure :author, :belongs_to_association 
  #     configure :reshares, :has_many_association 
  #     configure :o_embed_cache, :belongs_to_association 
  #     configure :likes, :has_many_association 
  #     configure :dislikes, :has_many_association 
  #     configure :comments, :has_many_association 
  #     configure :aspect_visibilities, :has_many_association 
  #     configure :aspects, :has_many_association 
  #     configure :share_visibilities, :has_many_association 
  #     configure :contacts, :has_many_association 
  #     configure :participations, :has_many_association 
  #     configure :mentions, :has_many_association 
  #     configure :resharers, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :author_id, :integer         # Hidden 
  #     configure :public, :boolean 
  #     configure :diaspora_handle, :string 
  #     configure :guid, :string 
  #     configure :pending, :boolean 
  #     configure :type, :string 
  #     configure :text, :text 
  #     configure :remote_photo_path, :text 
  #     configure :remote_photo_name, :string 
  #     configure :random_string, :string 
  #     configure :processed_image, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :unprocessed_image, :string 
  #     configure :object_url, :string 
  #     configure :image_url, :string 
  #     configure :image_height, :integer 
  #     configure :image_width, :integer 
  #     configure :provider_display_name, :string 
  #     configure :actor_url, :string 
  #     configure :objectId, :string 
  #     configure :root_guid, :string         # Hidden 
  #     configure :status_message_guid, :string 
  #     configure :likes_count, :integer 
  #     configure :comments_count, :integer 
  #     configure :o_embed_cache_id, :integer         # Hidden 
  #     configure :reshares_count, :integer 
  #     configure :interacted_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model ActsAsTaggableOn::Tag do
  #   # Found associations:
  #     configure :taggings, :has_many_association         # Hidden   #   # Found columns:
  #     configure :id, :integer 
  #     configure :name, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Aspect do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :aspect_memberships, :has_many_association 
  #     configure :contacts, :has_many_association 
  #     configure :aspect_visibilities, :has_many_association 
  #     configure :posts, :has_many_association 
  #     configure :photos, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :name, :string 
  #     configure :user_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :contacts_visible, :boolean 
  #     configure :order_id, :integer   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model AspectMembership do
  #   # Found associations:
  #     configure :aspect, :belongs_to_association 
  #     configure :contact, :belongs_to_association 
  #     configure :user, :has_one_association 
  #     configure :person, :has_one_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :aspect_id, :integer         # Hidden 
  #     configure :contact_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model AspectVisibility do
  #   # Found associations:
  #     configure :shareable, :polymorphic_association 
  #     configure :aspect, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :shareable_id, :integer         # Hidden 
  #     configure :shareable_type, :string         # Hidden 
  #     configure :aspect_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Block do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :person, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :person_id, :integer         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Comment do
  #   # Found associations:
  #     configure :commentable, :polymorphic_association 
  #     configure :author, :belongs_to_association 
  #     configure :likes, :has_many_association 
  #     configure :dislikes, :has_many_association 
  #     configure :taggings, :has_many_association         # Hidden 
  #     configure :base_tags, :has_many_association 
  #     configure :tag_taggings, :has_many_association         # Hidden 
  #     configure :tags, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :text, :text 
  #     configure :commentable_id, :integer         # Hidden 
  #     configure :commentable_type, :string         # Hidden 
  #     configure :author_id, :integer         # Hidden 
  #     configure :guid, :string 
  #     configure :author_signature, :text 
  #     configure :parent_author_signature, :text 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :likes_count, :integer   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Contact do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :person, :belongs_to_association 
  #     configure :aspect_memberships, :has_many_association 
  #     configure :aspects, :has_many_association 
  #     configure :share_visibilities, :has_many_association 
  #     configure :posts, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :person_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :sharing, :boolean 
  #     configure :receiving, :boolean   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Conversation do
  #   # Found associations:
  #     configure :author, :belongs_to_association 
  #     configure :conversation_visibilities, :has_many_association 
  #     configure :participants, :has_many_association 
  #     configure :messages, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :subject, :string 
  #     configure :guid, :string 
  #     configure :author_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model ConversationVisibility do
  #   # Found associations:
  #     configure :conversation, :belongs_to_association 
  #     configure :person, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :conversation_id, :integer         # Hidden 
  #     configure :person_id, :integer         # Hidden 
  #     configure :unread, :integer 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Invitation do
  #   # Found associations:
  #     configure :sender, :belongs_to_association 
  #     configure :recipient, :belongs_to_association 
  #     configure :aspect, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :message, :text 
  #     configure :sender_id, :integer         # Hidden 
  #     configure :recipient_id, :integer         # Hidden 
  #     configure :aspect_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :service, :string 
  #     configure :identifier, :string 
  #     configure :admin, :boolean 
  #     configure :language, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model InvitationCode do
  #   # Found associations:
  #     configure :user, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :token, :string 
  #     configure :user_id, :integer         # Hidden 
  #     configure :count, :integer 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Like do
  #   # Found associations:
  #     configure :target, :polymorphic_association 
  #     configure :author, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :positive, :boolean 
  #     configure :target_id, :integer         # Hidden 
  #     configure :target_type, :string         # Hidden 
  #     configure :author_id, :integer         # Hidden 
  #     configure :guid, :string 
  #     configure :author_signature, :text 
  #     configure :parent_author_signature, :text 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Mention do
  #   # Found associations:
  #     configure :post, :belongs_to_association 
  #     configure :person, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :post_id, :integer         # Hidden 
  #     configure :person_id, :integer         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Message do
  #   # Found associations:
  #     configure :conversation, :belongs_to_association 
  #     configure :author, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :conversation_id, :integer         # Hidden 
  #     configure :author_id, :integer         # Hidden 
  #     configure :guid, :string 
  #     configure :text, :text 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :author_signature, :text 
  #     configure :parent_author_signature, :text   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Notification do
  #   # Found associations:
  #     configure :target, :polymorphic_association 
  #     configure :recipient, :belongs_to_association 
  #     configure :notification_actors, :has_many_association 
  #     configure :actors, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :target_type, :string         # Hidden 
  #     configure :target_id, :integer         # Hidden 
  #     configure :recipient_id, :integer         # Hidden 
  #     configure :unread, :boolean 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :type, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model NotificationActor do
  #   # Found associations:
  #     configure :notification, :belongs_to_association 
  #     configure :person, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :notification_id, :integer         # Hidden 
  #     configure :person_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Notifications::AlsoCommented do
  #   # Found associations:
  #     configure :target, :polymorphic_association 
  #     configure :recipient, :belongs_to_association 
  #     configure :notification_actors, :has_many_association 
  #     configure :actors, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :target_type, :string         # Hidden 
  #     configure :target_id, :integer         # Hidden 
  #     configure :recipient_id, :integer         # Hidden 
  #     configure :unread, :boolean 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :type, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Notifications::CommentOnPost do
  #   # Found associations:
  #     configure :target, :polymorphic_association 
  #     configure :recipient, :belongs_to_association 
  #     configure :notification_actors, :has_many_association 
  #     configure :actors, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :target_type, :string         # Hidden 
  #     configure :target_id, :integer         # Hidden 
  #     configure :recipient_id, :integer         # Hidden 
  #     configure :unread, :boolean 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :type, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Notifications::Liked do
  #   # Found associations:
  #     configure :target, :polymorphic_association 
  #     configure :recipient, :belongs_to_association 
  #     configure :notification_actors, :has_many_association 
  #     configure :actors, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :target_type, :string         # Hidden 
  #     configure :target_id, :integer         # Hidden 
  #     configure :recipient_id, :integer         # Hidden 
  #     configure :unread, :boolean 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :type, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Notifications::Mentioned do
  #   # Found associations:
  #     configure :target, :polymorphic_association 
  #     configure :recipient, :belongs_to_association 
  #     configure :notification_actors, :has_many_association 
  #     configure :actors, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :target_type, :string         # Hidden 
  #     configure :target_id, :integer         # Hidden 
  #     configure :recipient_id, :integer         # Hidden 
  #     configure :unread, :boolean 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :type, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Notifications::PrivateMessage do
  #   # Found associations:
  #     configure :target, :polymorphic_association 
  #     configure :recipient, :belongs_to_association 
  #     configure :notification_actors, :has_many_association 
  #     configure :actors, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :target_type, :string         # Hidden 
  #     configure :target_id, :integer         # Hidden 
  #     configure :recipient_id, :integer         # Hidden 
  #     configure :unread, :boolean 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :type, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Notifications::RequestAccepted do
  #   # Found associations:
  #     configure :target, :polymorphic_association 
  #     configure :recipient, :belongs_to_association 
  #     configure :notification_actors, :has_many_association 
  #     configure :actors, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :target_type, :string         # Hidden 
  #     configure :target_id, :integer         # Hidden 
  #     configure :recipient_id, :integer         # Hidden 
  #     configure :unread, :boolean 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :type, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Notifications::Reshared do
  #   # Found associations:
  #     configure :target, :polymorphic_association 
  #     configure :recipient, :belongs_to_association 
  #     configure :notification_actors, :has_many_association 
  #     configure :actors, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :target_type, :string         # Hidden 
  #     configure :target_id, :integer         # Hidden 
  #     configure :recipient_id, :integer         # Hidden 
  #     configure :unread, :boolean 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :type, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Notifications::StartedSharing do
  #   # Found associations:
  #     configure :target, :polymorphic_association 
  #     configure :recipient, :belongs_to_association 
  #     configure :notification_actors, :has_many_association 
  #     configure :actors, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :target_type, :string         # Hidden 
  #     configure :target_id, :integer         # Hidden 
  #     configure :recipient_id, :integer         # Hidden 
  #     configure :unread, :boolean 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :type, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model OEmbedCache do
  #   # Found associations:
  #     configure :posts, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :url, :string 
  #     configure :data, :serialized   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Participation do
  #   # Found associations:
  #     configure :target, :polymorphic_association 
  #     configure :author, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :guid, :string 
  #     configure :target_id, :integer         # Hidden 
  #     configure :target_type, :string         # Hidden 
  #     configure :author_id, :integer         # Hidden 
  #     configure :author_signature, :text 
  #     configure :parent_author_signature, :text 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Person do
  #   # Found associations:
  #     configure :owner, :belongs_to_association 
  #     configure :profile, :has_one_association 
  #     configure :contacts, :has_many_association 
  #     configure :posts, :has_many_association 
  #     configure :photos, :has_many_association 
  #     configure :comments, :has_many_association 
  #     configure :participations, :has_many_association 
  #     configure :notification_actors, :has_many_association 
  #     configure :notifications, :has_many_association 
  #     configure :mentions, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :guid, :string 
  #     configure :url, :text 
  #     configure :diaspora_handle, :string 
  #     configure :serialized_public_key, :text 
  #     configure :owner_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :closed_account, :boolean   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Photo do
  #   # Found associations:
  #     configure :author, :belongs_to_association 
  #     configure :status_message, :belongs_to_association 
  #     configure :comments, :has_many_association 
  #     configure :aspect_visibilities, :has_many_association 
  #     configure :aspects, :has_many_association 
  #     configure :share_visibilities, :has_many_association 
  #     configure :contacts, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :tmp_old_id, :integer 
  #     configure :author_id, :integer         # Hidden 
  #     configure :public, :boolean 
  #     configure :diaspora_handle, :string 
  #     configure :guid, :string 
  #     configure :pending, :boolean 
  #     configure :text, :text 
  #     configure :remote_photo_path, :text 
  #     configure :remote_photo_name, :string 
  #     configure :random_string, :string 
  #     configure :processed_image, :carrierwave 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :unprocessed_image, :carrierwave 
  #     configure :status_message_guid, :string         # Hidden 
  #     configure :comments_count, :integer   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Pod do
  #   # Found associations:
  #   # Found columns:
  #     configure :id, :integer 
  #     configure :host, :string 
  #     configure :ssl, :boolean 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Post do
  #   # Found associations:
  #     configure :author, :belongs_to_association 
  #     configure :reshares, :has_many_association 
  #     configure :o_embed_cache, :belongs_to_association 
  #     configure :likes, :has_many_association 
  #     configure :dislikes, :has_many_association 
  #     configure :comments, :has_many_association 
  #     configure :aspect_visibilities, :has_many_association 
  #     configure :aspects, :has_many_association 
  #     configure :share_visibilities, :has_many_association 
  #     configure :contacts, :has_many_association 
  #     configure :participations, :has_many_association 
  #     configure :mentions, :has_many_association 
  #     configure :resharers, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :author_id, :integer         # Hidden 
  #     configure :public, :boolean 
  #     configure :diaspora_handle, :string 
  #     configure :guid, :string 
  #     configure :pending, :boolean 
  #     configure :type, :string 
  #     configure :text, :text 
  #     configure :remote_photo_path, :text 
  #     configure :remote_photo_name, :string 
  #     configure :random_string, :string 
  #     configure :processed_image, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :unprocessed_image, :string 
  #     configure :object_url, :string 
  #     configure :image_url, :string 
  #     configure :image_height, :integer 
  #     configure :image_width, :integer 
  #     configure :provider_display_name, :string 
  #     configure :actor_url, :string 
  #     configure :objectId, :string 
  #     configure :root_guid, :string         # Hidden 
  #     configure :status_message_guid, :string 
  #     configure :likes_count, :integer 
  #     configure :comments_count, :integer 
  #     configure :o_embed_cache_id, :integer         # Hidden 
  #     configure :reshares_count, :integer 
  #     configure :interacted_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Profile do
  #   # Found associations:
  #     configure :person, :belongs_to_association 
  #     configure :taggings, :has_many_association         # Hidden 
  #     configure :base_tags, :has_many_association 
  #     configure :tag_taggings, :has_many_association         # Hidden 
  #     configure :tags, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :diaspora_handle, :string 
  #     configure :first_name, :string 
  #     configure :last_name, :string 
  #     configure :image_url, :string 
  #     configure :image_url_small, :string 
  #     configure :image_url_medium, :string 
  #     configure :birthday, :date 
  #     configure :gender, :string 
  #     configure :bio, :text 
  #     configure :searchable, :boolean 
  #     configure :person_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :location, :string 
  #     configure :full_name, :string 
  #     configure :nsfw, :boolean   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Reshare do
  #   # Found associations:
  #     configure :author, :belongs_to_association 
  #     configure :reshares, :has_many_association 
  #     configure :o_embed_cache, :belongs_to_association 
  #     configure :likes, :has_many_association 
  #     configure :dislikes, :has_many_association 
  #     configure :comments, :has_many_association 
  #     configure :aspect_visibilities, :has_many_association 
  #     configure :aspects, :has_many_association 
  #     configure :share_visibilities, :has_many_association 
  #     configure :contacts, :has_many_association 
  #     configure :participations, :has_many_association 
  #     configure :mentions, :has_many_association 
  #     configure :resharers, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :author_id, :integer         # Hidden 
  #     configure :public, :boolean 
  #     configure :diaspora_handle, :string 
  #     configure :guid, :string 
  #     configure :pending, :boolean 
  #     configure :type, :string 
  #     configure :text, :text 
  #     configure :remote_photo_path, :text 
  #     configure :remote_photo_name, :string 
  #     configure :random_string, :string 
  #     configure :processed_image, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :unprocessed_image, :string 
  #     configure :object_url, :string 
  #     configure :image_url, :string 
  #     configure :image_height, :integer 
  #     configure :image_width, :integer 
  #     configure :provider_display_name, :string 
  #     configure :actor_url, :string 
  #     configure :objectId, :string 
  #     configure :root_guid, :string         # Hidden 
  #     configure :status_message_guid, :string 
  #     configure :likes_count, :integer 
  #     configure :comments_count, :integer 
  #     configure :o_embed_cache_id, :integer         # Hidden 
  #     configure :reshares_count, :integer 
  #     configure :interacted_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Service do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :service_users, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :type, :string 
  #     configure :user_id, :integer         # Hidden 
  #     configure :uid, :string 
  #     configure :access_token, :string 
  #     configure :access_secret, :string 
  #     configure :nickname, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Services::Facebook do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :service_users, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :type, :string 
  #     configure :user_id, :integer         # Hidden 
  #     configure :uid, :string 
  #     configure :access_token, :string 
  #     configure :access_secret, :string 
  #     configure :nickname, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Services::Tumblr do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :service_users, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :type, :string 
  #     configure :user_id, :integer         # Hidden 
  #     configure :uid, :string 
  #     configure :access_token, :string 
  #     configure :access_secret, :string 
  #     configure :nickname, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Services::Twitter do
  #   # Found associations:
  #     configure :user, :belongs_to_association 
  #     configure :service_users, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :type, :string 
  #     configure :user_id, :integer         # Hidden 
  #     configure :uid, :string 
  #     configure :access_token, :string 
  #     configure :access_secret, :string 
  #     configure :nickname, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model ShareVisibility do
  #   # Found associations:
  #     configure :shareable, :polymorphic_association 
  #     configure :contact, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :shareable_id, :integer         # Hidden 
  #     configure :shareable_type, :string         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :hidden, :boolean 
  #     configure :contact_id, :integer         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model StatusMessage do
  #   # Found associations:
  #     configure :author, :belongs_to_association 
  #     configure :reshares, :has_many_association 
  #     configure :photos, :has_many_association 
  #     configure :o_embed_cache, :belongs_to_association 
  #     configure :likes, :has_many_association 
  #     configure :dislikes, :has_many_association 
  #     configure :comments, :has_many_association 
  #     configure :aspect_visibilities, :has_many_association 
  #     configure :aspects, :has_many_association 
  #     configure :share_visibilities, :has_many_association 
  #     configure :contacts, :has_many_association 
  #     configure :participations, :has_many_association 
  #     configure :mentions, :has_many_association 
  #     configure :resharers, :has_many_association 
  #     configure :taggings, :has_many_association         # Hidden 
  #     configure :base_tags, :has_many_association 
  #     configure :tag_taggings, :has_many_association         # Hidden 
  #     configure :tags, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :author_id, :integer         # Hidden 
  #     configure :public, :boolean 
  #     configure :diaspora_handle, :string 
  #     configure :guid, :string 
  #     configure :pending, :boolean 
  #     configure :type, :string 
  #     configure :text, :text 
  #     configure :remote_photo_path, :text 
  #     configure :remote_photo_name, :string 
  #     configure :random_string, :string 
  #     configure :processed_image, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :unprocessed_image, :string 
  #     configure :object_url, :string 
  #     configure :image_url, :string 
  #     configure :image_height, :integer 
  #     configure :image_width, :integer 
  #     configure :provider_display_name, :string 
  #     configure :actor_url, :string 
  #     configure :objectId, :string 
  #     configure :root_guid, :string         # Hidden 
  #     configure :status_message_guid, :string         # Hidden 
  #     configure :likes_count, :integer 
  #     configure :comments_count, :integer 
  #     configure :o_embed_cache_id, :integer         # Hidden 
  #     configure :reshares_count, :integer 
  #     configure :interacted_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model TagFollowing do
  #   # Found associations:
  #     configure :tag, :belongs_to_association 
  #     configure :user, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :tag_id, :integer         # Hidden 
  #     configure :user_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model User do
  #   # Found associations:
  #     configure :invited_by, :belongs_to_association 
  #     configure :auto_follow_back_aspect, :belongs_to_association 
  #     configure :person, :has_one_association 
  #     configure :invitations_from_me, :has_many_association 
  #     configure :invitations_to_me, :has_many_association 
  #     configure :aspects, :has_many_association 
  #     configure :aspect_memberships, :has_many_association 
  #     configure :contacts, :has_many_association 
  #     configure :contact_people, :has_many_association 
  #     configure :services, :has_many_association 
  #     configure :user_preferences, :has_many_association 
  #     configure :tag_followings, :has_many_association 
  #     configure :followed_tags, :has_many_association 
  #     configure :blocks, :has_many_association 
  #     configure :ignored_people, :has_many_association 
  #     configure :notifications, :has_many_association 
  #     configure :authorizations, :has_many_association         # Hidden 
  #     configure :applications, :has_many_association         # Hidden   #   # Found columns:
  #     configure :id, :integer 
  #     configure :username, :string 
  #     configure :serialized_private_key, :text 
  #     configure :getting_started, :boolean 
  #     configure :disable_mail, :boolean 
  #     configure :language, :string 
  #     configure :email, :string 
  #     configure :password, :password         # Hidden 
  #     configure :password_confirmation, :password         # Hidden 
  #     configure :reset_password_token, :string         # Hidden 
  #     configure :remember_token, :string         # Hidden 
  #     configure :invitation_token, :string 
  #     configure :invitation_sent_at, :datetime 
  #     configure :remember_created_at, :datetime 
  #     configure :sign_in_count, :integer 
  #     configure :current_sign_in_at, :datetime 
  #     configure :last_sign_in_at, :datetime 
  #     configure :current_sign_in_ip, :string 
  #     configure :last_sign_in_ip, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :invitation_service, :string 
  #     configure :invitation_identifier, :string 
  #     configure :invitation_limit, :integer 
  #     configure :invited_by_id, :integer         # Hidden 
  #     configure :invited_by_type, :string 
  #     configure :authentication_token, :string 
  #     configure :unconfirmed_email, :string 
  #     configure :confirm_email_token, :string 
  #     configure :locked_at, :datetime 
  #     configure :show_community_spotlight_in_stream, :boolean 
  #     configure :auto_follow_back, :boolean 
  #     configure :auto_follow_back_aspect_id, :integer         # Hidden 
  #     configure :hidden_shareables, :serialized   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model UserPreference do
  #   # Found associations:
  #     configure :user, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :email_type, :string 
  #     configure :user_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
end
end