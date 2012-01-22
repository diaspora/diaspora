namespace :assets do
	task :precompile do
    system 'sass --update public/stylesheets/sass:public/stylesheets'
    system 'bundle exec jammit'
	end
end