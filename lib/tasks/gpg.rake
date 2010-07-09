namespace :gpg do
  desc 'Clear the gpg keyrings'
  task :clear do
    ctx = GPGME::Ctx.new
    keys = ctx.keys
    keys.each{|k| ctx.delete_key(k, true)}
  end
end
