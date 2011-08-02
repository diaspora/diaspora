desc 'Make all files use UNIX (\n) line endings'
task :fix_cr_lf do
  files = FileList['**/*']
  files.each do |f|
    next if File.directory?(f) || f =~ /dos/
    s = IO.read(f)
    s.gsub!(/\r?\n/, "\n")
    File.open(f, "w") { |io| io.write(s) }
  end
end