
begin
  require 'bones/smtp_tls'
rescue LoadError
  require 'net/smtp'
end
require 'time'

namespace :ann do

  # A prerequisites task that all other tasks depend upon
  task :prereqs

  file PROJ.ann.file do
    ann = PROJ.ann
    puts "Generating #{ann.file}"
    File.open(ann.file,'w') do |fd|
      fd.puts("#{PROJ.name} version #{PROJ.version}")
      fd.puts("    by #{Array(PROJ.authors).first}") if PROJ.authors
      fd.puts("    #{PROJ.url}") if PROJ.url.valid?
      fd.puts("    (the \"#{PROJ.release_name}\" release)") if PROJ.release_name
      fd.puts
      fd.puts("== DESCRIPTION")
      fd.puts
      fd.puts(PROJ.description)
      fd.puts
      fd.puts(PROJ.changes.sub(%r/^.*$/, '== CHANGES'))
      fd.puts
      ann.paragraphs.each do |p|
        fd.puts "== #{p.upcase}"
        fd.puts
        fd.puts paragraphs_of(PROJ.readme_file, p).join("\n\n")
        fd.puts
      end
      fd.puts ann.text if ann.text
    end
  end

  desc "Create an announcement file"
  task :announcement => ['ann:prereqs', PROJ.ann.file]

  desc "Send an email announcement"
  task :email => ['ann:prereqs', PROJ.ann.file] do
    ann = PROJ.ann
    from = ann.email[:from] || Array(PROJ.authors).first || PROJ.email
    to   = Array(ann.email[:to])

    ### build a mail header for RFC 822
    rfc822msg =  "From: #{from}\n"
    rfc822msg << "To: #{to.join(',')}\n"
    rfc822msg << "Subject: [ANN] #{PROJ.name} #{PROJ.version}"
    rfc822msg << " (#{PROJ.release_name})" if PROJ.release_name
    rfc822msg << "\n"
    rfc822msg << "Date: #{Time.new.rfc822}\n"
    rfc822msg << "Message-Id: "
    rfc822msg << "<#{"%.8f" % Time.now.to_f}@#{ann.email[:domain]}>\n\n"
    rfc822msg << File.read(ann.file)

    params = [:server, :port, :domain, :acct, :passwd, :authtype].map do |key|
      ann.email[key]
    end

    params[3] = (PROJ.ann.email[:from] || PROJ.email) if params[3].nil?

    if params[4].nil?
      STDOUT.write "Please enter your e-mail password (#{params[3]}): "
      params[4] = STDIN.gets.chomp
    end

    ### send email
    Net::SMTP.start(*params) {|smtp| smtp.sendmail(rfc822msg, from, to)}
  end
end  # namespace :ann

desc 'Alias to ann:announcement'
task :ann => 'ann:announcement'

CLOBBER << PROJ.ann.file

# EOF
