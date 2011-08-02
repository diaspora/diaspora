ActiveRecord::Schema.define do
 
  create_table :books, :options=>'ENGINE=MyISAM', :force=>true do |t|
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
  execute "ALTER TABLE books ADD FULLTEXT( `title`, `publisher`, `author_name` )"

end
