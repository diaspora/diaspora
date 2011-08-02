module DeviseInvitable
  module Schema
    # Add invitation_token and invitation_sent_at columns in the resource's database table.
    #
    # Examples
    #
    #   # For a new resource migration:
    #   create_table :the_resources do
    #     t.database_authenticatable :null => false # you need at least this
    #     t.invitable
    #     ...
    #   end
    #   add_index :the_resources, :invitation_token # for invitable
    #
    #   # or if the resource's table already exists, define a migration and put this in:
    #   change_table :the_resources do |t|
    #     t.string   :invitation_token, :limit => 60
    #     t.datetime :invitation_sent_at
    #     t.index    :invitation_token # for invitable
    #   end
    #
    #   # And allow encrypted_password to be null:
    #   change_column :the_resources, :encrypted_password, :string, :null => true
    #   # the following line is only if you use Devise's encryptable module!
    #   change_column :the_resources, :password_salt,      :string, :null => true
    def invitable
      apply_devise_schema :invitation_token,   String, :limit => 60
      apply_devise_schema :invitation_sent_at, DateTime
      apply_devise_schema :invitation_limit, Integer
      apply_devise_schema :invited_by_id, Integer
      apply_devise_schema :invited_by_type, String
    end
  end
end

Devise::Schema.send :include, DeviseInvitable::Schema
