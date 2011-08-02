require 'helper'
require 'foreigner/connection_adapters/mysql_adapter'

class MysqlAdapterTest < ActiveRecord::TestCase
  include Foreigner::ConnectionAdapters::MysqlAdapter

  def test_add_without_options
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id)",
      add_foreign_key(:employees, :companies)
    )
  end
  
  def test_add_with_name
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `favorite_company_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id)",
      add_foreign_key(:employees, :companies, :name => 'favorite_company_fk')
    )
  end
  
  def test_add_with_column
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_last_employer_id_fk` FOREIGN KEY (`last_employer_id`) REFERENCES `companies`(id)",
      add_foreign_key(:employees, :companies, :column => 'last_employer_id')
    ) 
  end
  
  def test_add_with_column_and_name
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `favorite_company_fk` FOREIGN KEY (`last_employer_id`) REFERENCES `companies`(id)",
      add_foreign_key(:employees, :companies, :column => 'last_employer_id', :name => 'favorite_company_fk')
    )
  end
  
  def test_add_with_delete_dependency
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "ON DELETE CASCADE",
      add_foreign_key(:employees, :companies, :dependent => :delete)
    )
  end
  
  def test_add_with_nullify_dependency
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "ON DELETE SET NULL",
      add_foreign_key(:employees, :companies, :dependent => :nullify)
    )
  end
  
  def test_add_with_restrict_dependency
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "ON DELETE RESTRICT",
      add_foreign_key(:employees, :companies, :dependent => :restrict)
    )
  end

  def test_add_with_options
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "on delete foo",
      add_foreign_key(:employees, :companies, :options => 'on delete foo')
    )
  end
  
  def test_remove_by_table
    assert_equal(
      "ALTER TABLE `suppliers` DROP FOREIGN KEY `suppliers_company_id_fk`",
      remove_foreign_key(:suppliers, :companies)
    )
  end
  
  def test_remove_by_name
    assert_equal(
      "ALTER TABLE `suppliers` DROP FOREIGN KEY `belongs_to_supplier`",
      remove_foreign_key(:suppliers, :name => "belongs_to_supplier")
    )
  end
  
  def test_remove_by_column
    assert_equal(
      "ALTER TABLE `suppliers` DROP FOREIGN KEY `suppliers_ship_to_id_fk`",
      remove_foreign_key(:suppliers, :column => "ship_to_id")
    )
  end
  
  private
    def execute(sql, name = nil)
      sql
    end
  
    def quote_column_name(name)
      "`#{name}`"
    end
    
    def quote_table_name(name)
      quote_column_name(name).gsub('.', '`.`')
    end
end