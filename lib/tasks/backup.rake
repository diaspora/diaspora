namespace :backup do
  desc "Backup Mongo"
  task :mongo do
      cf = CloudFiles::Connection.new(:username => "", :api_key => "")
      mongo_container = cf.container("Mongo Backup")
      file = cont.create_object("test.txt")
      file.write "Things"
  end
end
