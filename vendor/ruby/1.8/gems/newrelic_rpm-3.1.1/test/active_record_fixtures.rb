# Some test models
# These will get created and dropped during the active record tests
# Be sure and call setup and teardown
module ActiveRecordFixtures
  extend self
  def setup
    ActiveRecordFixtures::Order.setup
    ActiveRecordFixtures::Shipment.setup
  end
  def teardown
    ActiveRecordFixtures::Shipment.teardown
    ActiveRecordFixtures::Order.teardown
    begin
      super
    rescue Exception => e
    end
  end
  class Order < ActiveRecord::Base
    self.table_name = 'newrelic_test_orders'
    has_and_belongs_to_many :shipments, :class_name => 'ActiveRecordFixtures::Shipment'
    def self.setup
      unless check_for_table
        connection.create_table self.table_name, :force => true do |t|
          t.column :name, :string
        end
      else
        connection.execute("delete from #{self.table_name}")
      end
    end

    def self.check_for_table
      connection.table_exists?(self.table_name)
    rescue Exception => e
      false
    end
    
    def self.add_delay
      # Introduce a 5 ms delay into db operations on Orders
      def connection.log_info *args
        sleep 0.005
        super *args
      end
    end
    def self.teardown
      def connection.log_info *args
        super *args
      end
    end
  end

  class Shipment < ActiveRecord::Base
    self.table_name = 'newrelic_test_shipment'
    has_and_belongs_to_many :orders, :class_name => 'ActiveRecordFixtures::Order'
    def self.setup
      unless check_for_table
        connection.create_table self.table_name, :force => true do |t|
          # no other columns
        end
        connection.create_table 'orders_shipments', :force => true, :id => false do |t|
          t.column :order_id, :integer
          t.column :shipment_id, :integer
        end
      else
        connection.execute("delete from #{self.table_name}")
      end
    end
    def self.check_for_table
      connection.table_exists?(self.table_name) && connection.table_exists?('orders_shipments')
    rescue Exception => e
      false
    end

    
    def self.teardown
    end
  end
end
