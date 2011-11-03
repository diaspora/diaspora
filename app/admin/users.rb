ActiveAdmin.register User do
  
  filter :username
  filter :email
  
  index do
    column :username
    column :email
  end
  
end
