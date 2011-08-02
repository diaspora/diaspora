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

    create_table :category_groups, :force => true do |t|
      t.string :name
    end

    create_table :categories, :force => true do |t|
      t.integer :category_group_id
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

class CategoryGroup < ActiveRecord::Base
end

class Category < ActiveRecord::Base
  belongs_to :category_group
end

class Post < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  belongs_to :category
end

class NonActiveRecord
end

FactoryGirl.define do
  # To make sure the step defs work with an email
  sequence :email do |n|
    "email#{n}@example.com"
  end

  factory :user, :aliases => [:person] do
    factory :admin_user do
      admin true
    end
  end

  factory :category do
    name "programming"
    category_group
  end

  factory :category_group do
    name "tecnhology"
  end

  factory :post do
    association :author, :factory => :user
    category
  end

  # This is here to ensure that factory step definitions don't raise for a non-AR factory
  factory :non_active_record do
  end
end

require 'factory_girl/step_definitions'

