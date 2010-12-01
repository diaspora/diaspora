ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => File.join(File.dirname(__FILE__), 'test.db')
)

class CreateSchema < ActiveRecord::Migration
  def self.up
    create_table :posts, :force => true do |t|
      t.integer :author_id
      t.integer :category_id
      t.string  :title
      t.string  :body
    end

    create_table :categories, :force => true do |t|
      t.string :name
    end

    create_table :users, :force => true do |t|
      t.string  :name
      t.boolean :admin, :default => false, :null => false
    end
  end
end

CreateSchema.suppress_messages { CreateSchema.migrate(:up) }

class User < ActiveRecord::Base
end

class Category < ActiveRecord::Base
end

class Post < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  belongs_to :category
end

class NonActiveRecord
end

Factory.define :user do |f|
end

Factory.define :admin_user, :parent => :user do |f|
  f.admin true
end

Factory.define :category do |f|
  f.name "programming"
end

Factory.define :post do |f|
  f.association :author, :factory => :user
  f.association :category
end

# This is here to ensure that factory step definitions don't raise for a non-AR factory
Factory.define :non_active_record do |f|
end

require 'factory_girl/step_definitions'
