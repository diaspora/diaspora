class Admin < User
  has_many :companies, :finder_sql => 'SELECT * FROM companies'
end
