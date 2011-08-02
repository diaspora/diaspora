module Aws

    # This class is a special array to hold a bit of extra information about a response like:
    # <ResponseMetadata>
    #    <RequestId>4f1fae46-bf3d-11de-a88b-7b5b3d23b3a7</RequestId>
    #  </ResponseMetadata>
    #
    # Which can be accessed directly from the array using array.response_metadata
    #
    class AwsResponseArray < Array

        attr_accessor :response_metadata

        def initialize(response_metadata)
            @response_metadata = response_metadata
        end

    end

    # Used when pulling out a single response object
    class AwsResponseObjectHash < Hash

        attr_accessor :response_metadata

        def initialize(response_metadata)
            @response_metadata = response_metadata
        end

    end
end