class GridfsController < ActionController::Metal
  def serve
    gridfs_path = env["PATH_INFO"].gsub("/images/", "")
    begin
      gridfs_file = Mongo::GridFileSystem.new(MongoMapper.database).open(gridfs_path, 'r')
      self.response_body = gridfs_file.read
      self.content_type = gridfs_file.content_type
    rescue
      self.status = :file_not_found
      self.content_type = 'text/plain'
      self.response_body = "File totally imaginary #{gridfs_path}"
    end
  end
end
