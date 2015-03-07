
class UndigestedAssets
  def initialize(app)
    @app = app
    @asset_prefix = Rails.configuration.assets.prefix

    load_manifest
  end

  def call(env)
    if m = (env['PATH_INFO'] || '').match(/#{@asset_prefix}\/(.+)/i)
      file = m[1]

      if manifest_available? && undigested_file?(file)
        return [307, { "Location" => File.join('', @asset_prefix, @manifest[file])}, ["See other"]]
      end
    end

    @app.call(env)
  end

  private

  def load_manifest
    manifest_path = Dir.glob(Rails.root.join("public", "assets", "manifest-*.json")).first
    @manifest = JSON.load(File.new(manifest_path))["assets"] if File.exists?(manifest_path)
  end

  def undigested_file?(filename)
    @manifest.has_key?(filename)
  end

  def manifest_available?
    !@manifest.nil?
  end
end
