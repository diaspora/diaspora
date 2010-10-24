cookbook_file "/etc/yum.repos.d/10gen.repo" do
  source "10gen.repo"
end

execute "refresh yum" do
  command "yum update -y"
end

execute "install mongo" do
  command "yum install -y mongo-stable"
end
