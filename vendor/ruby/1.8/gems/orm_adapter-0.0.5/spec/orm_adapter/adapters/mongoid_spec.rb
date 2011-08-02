require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(Mongoid) || !(Mongo::Connection.new.db('orm_adapter_spec') rescue nil)
  puts "** require 'mongoid' and start mongod to run the specs in #{__FILE__}"
else  
  
  Mongoid.configure do |config|
    config.master = Mongo::Connection.new.db('orm_adapter_spec')
  end
  
  module MongoidOrmSpec
    class User
      include Mongoid::Document
      field :name
      field :rating
      has_many_related :notes, :foreign_key => :owner_id, :class_name => 'MongoidOrmSpec::Note'
    end

    class Note
      include Mongoid::Document
      field :body, :default => "made by orm"
      belongs_to_related :owner, :class_name => 'MongoidOrmSpec::User'
    end
    
    # here be the specs!
    describe Mongoid::Document::OrmAdapter do
      before do
        User.delete_all
        Note.delete_all
      end
      
      describe "the OrmAdapter class" do
        subject { Mongoid::Document::OrmAdapter }

        specify "#model_classes should return all document classes" do
          (subject.model_classes & [User, Note]).to_set.should == [User, Note].to_set
        end
      end
    
      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
      end
    end
  end
end