class RemoveDuplicateAspectVisibilities < ActiveRecord::Migration[4.2]
  def up
    where = "WHERE a1.aspect_id = a2.aspect_id AND a1.shareable_id = a2.shareable_id AND "\
      "a1.shareable_type = a2.shareable_type AND a1.id > a2.id"
    if AppConfig.postgres?
      execute("DELETE FROM aspect_visibilities AS a1 USING aspect_visibilities AS a2 #{where}")
    else
      execute("DELETE a1 FROM aspect_visibilities a1, aspect_visibilities a2 #{where}")
    end
  end
end
