Shindo.tests('AWS::Storage | object requests', ['aws']) do

  @directory = AWS[:storage].directories.create(:key => 'fogmultipartuploadtests')

  tests('success') do

    @initiate_multipart_upload_format = {
      'Bucket'    => String,
      'Key'       => String,
      'UploadId'  => String
    }

    tests("#initiate_multipart_upload('#{@directory.identity}')", 'fog_multipart_upload').formats(@initiate_multipart_upload_format) do
      pending if Fog.mocking?
      data = AWS[:storage].initiate_multipart_upload(@directory.identity, 'fog_multipart_upload').body
      @upload_id = data['UploadId']
      data
    end

    @list_multipart_uploads_format = {
      'Bucket'              => String,
      'IsTruncated'         => Fog::Boolean,
      'MaxUploads'          => Integer,
      'KeyMarker'           => NilClass,
      'NextKeyMarker'       => String,
      'NextUploadIdMarker'  => String,
      'Upload' => [{
        'Initiated'     => Time,
        'Initiator' => {
          'DisplayName' => String,
          'ID'          => String
        },
        'Key'           => String,
        'Owner' => {
          'DisplayName' => String,
          'ID'          => String
        },
        'StorageClass'      => String,
        'UploadId'          => String
      }],
      'UploadIdMarker'      => NilClass,
    }

    tests("#list_multipart_uploads('#{@directory.identity})").formats(@list_multipart_uploads_format) do
      pending if Fog.mocking?
      AWS[:storage].list_multipart_uploads(@directory.identity).body
    end

    @parts = []

    tests("#upload_part('#{@directory.identity}', 'fog_multipart_upload', '#{@upload_id}', 1, ('x' * 6 * 1024 * 1024))").succeeds do
      pending if Fog.mocking?
      data = AWS[:storage].upload_part(@directory.identity, 'fog_multipart_upload', @upload_id, 1, ('x' * 6 * 1024 * 1024))
      @parts << data.headers['ETag']
    end

    @list_parts_format = {
      'Bucket'            => String,
      'Initiator' => {
        'DisplayName'     => String,
        'ID'              => String
      },
      'IsTruncated'       => Fog::Boolean,
      'Key'               => String,
      'MaxParts'          => Integer,
      'NextPartNumberMarker' => String,
      'Part' => [{
        'ETag'            => String,
        'LastModified'    => Time,
        'PartNumber'      => Integer,
        'Size'            => Integer
      }],
      'PartNumberMarker'  => String,
      'StorageClass'      => String,
      'UploadId'          => String
    }

    tests("#list_parts('#{@directory.identity}', 'fog_multipart_upload', '#{@upload_id}')").formats(@list_parts_format) do
      pending if Fog.mocking?
      AWS[:storage].list_parts(@directory.identity, 'fog_multipart_upload', @upload_id).body
    end

    if !Fog.mocking?
      @parts << AWS[:storage].upload_part(@directory.identity, 'fog_multipart_upload', @upload_id, 2, ('x' * 4 * 1024 * 1024)).headers['ETag']
    end

    @complete_multipart_upload_format = {
      'Bucket'    => String,
      'ETag'      => String,
      'Key'       => String,
      'Location'  => String
    }

    tests("#complete_multipart_upload('#{@directory.identity}', 'fog_multipart_upload', '#{@upload_id}', #{@parts.inspect})").formats(@complete_multipart_upload_format) do
      pending if Fog.mocking?
      AWS[:storage].complete_multipart_upload(@directory.identity, 'fog_multipart_upload', @upload_id, @parts).body
    end

    tests("#get_object('#{@directory.identity}', 'fog_multipart_upload').body").succeeds do
      pending if Fog.mocking?
      data = AWS[:storage].get_object(@directory.identity, 'fog_multipart_upload').body
      unless data == ('x' * 10 * 1024 * 1024)
        raise 'content mismatch'
      end
    end

    if !Fog.mocking?
      @directory.files.new(:key => 'fog_multipart_upload').destroy
    end

    if !Fog.mocking?
      @upload_id = AWS[:storage].initiate_multipart_upload(@directory.identity, 'fog_multipart_abort').body['UploadId']
    end

    tests("#abort_multipart_upload('#{@directory.identity}', 'fog_multipart_abort', '#{@upload_id}')").succeeds do
      pending if Fog.mocking?
      AWS[:storage].abort_multipart_upload(@directory.identity, 'fog_multipart_abort', @upload_id)
    end

  end

  tests('failure') do

    tests("initiate_multipart_upload")
    tests("list_multipart_uploads")
    tests("upload_part")
    tests("list_parts")
    tests("complete_multipart_upload")
    tests("abort_multipart_upload")

  end

  @directory.destroy

end
