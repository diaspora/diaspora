ActiveRecord::Schema.define do

  create_table :schema_info, :force=>true do |t|
    t.column :version, :integer, :unique=>true
  end
  SchemaInfo.create :version=>SchemaInfo::VERSION

  create_table :group, :force => true do |t|
    t.column :order, :string
    t.timestamps
  end

  create_table :topics, :force=>true do |t|
    t.column :title, :string, :null => false
    t.column :author_name, :string
    t.column :author_email_address, :string
    t.column :written_on, :datetime
    t.column :bonus_time, :time
    t.column :last_read, :datetime
    t.column :content, :text
    t.column :approved, :boolean, :default=>'1'
    t.column :replies_count, :integer
    t.column :parent_id, :integer
    t.column :type, :string
    t.column :created_at, :datetime
    t.column :created_on, :datetime
    t.column :updated_at, :datetime
    t.column :updated_on, :datetime
  end

  create_table :projects, :force=>true do |t|
    t.column :name, :string
    t.column :type, :string    
  end
  
  create_table :developers, :force=>true do |t|
    t.column :name, :string
    t.column :salary, :integer, :default=>'70000'
    t.column :created_at, :datetime
    t.column :team_id, :integer
    t.column :updated_at, :datetime
  end

  create_table :addresses, :force=>true do |t|
    t.column :address, :string
    t.column :city, :string
    t.column :state, :string
    t.column :zip, :string
    t.column :developer_id, :integer
  end

  create_table :teams, :force=>true do |t|
    t.column :name, :string
  end
  
  create_table :books, :force=>true do |t|
    t.column :title, :string, :null=>false
    t.column :publisher, :string, :null=>false, :default => 'Default Publisher'
    t.column :author_name, :string, :null=>false
    t.column :created_at, :datetime
    t.column :created_on, :datetime
    t.column :updated_at, :datetime
    t.column :updated_on, :datetime
    t.column :publish_date, :date
    t.column :topic_id, :integer
    t.column :for_sale, :boolean, :default => true
  end  

  create_table :languages, :force=>true do |t|
    t.column :name, :string
    t.column :developer_id, :integer
  end

  create_table :shopping_carts, :force=>true do |t|
    t.column :name, :string, :null => true
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end

  create_table :cart_items, :force => true do |t|
    t.column :shopping_cart_id, :string, :null => false
    t.column :book_id, :string, :null => false
    t.column :copies, :integer, :default => 1
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end

  add_index :cart_items, [:shopping_cart_id, :book_id], :unique => true, :name => 'uk_shopping_cart_books'

  create_table :animals, :force => true do |t|
    t.column :name, :string, :null => false
    t.column :size, :string, :default => nil
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end
  
  add_index :animals, [:name], :unique => true, :name => 'uk_animals'
end
