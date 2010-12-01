
if HAVE_BONES

desc "Enumerate all annotations"
task :notes do |t|
  id = if t.application.top_level_tasks.length > 1
    t.application.top_level_tasks.slice!(1..-1).join(' ')
  end
  Bones::AnnotationExtractor.enumerate(
      PROJ, PROJ.notes.tags.join('|'), id, :tag => true)
end

namespace :notes do
  PROJ.notes.tags.each do |tag|
    desc "Enumerate all #{tag} annotations"
    task tag.downcase.to_sym do |t|
      id = if t.application.top_level_tasks.length > 1
        t.application.top_level_tasks.slice!(1..-1).join(' ')
      end
      Bones::AnnotationExtractor.enumerate(PROJ, tag, id)
    end
  end
end

end  # if HAVE_BONES

# EOF
