module CommonHelpers
  def in_tmp_folder(&block)
    FileUtils.chdir(@tmp_root, &block)
  end

  def in_project_folder(&block)
    project_folder = @active_project_folder || @tmp_root
    FileUtils.chdir(project_folder, &block)
  end

  def in_home_folder(&block)
    FileUtils.chdir(@home_path, &block)
  end

  def force_local_lib_override(options = {})
    target_path = options[:target_path] || options[:target_file] || options[:target] || 'Rakefile'
    in_project_folder do
      contents = File.read(target_path)
      File.open(target_path, "w+") do |f|
        f << "$:.unshift('#{@lib_path}')\n"
        f << contents
      end
    end
  end

  def setup_active_project_folder project_name
    @active_project_folder = File.join(@tmp_root, project_name)
    @project_name = project_name
  end
end

World(CommonHelpers)