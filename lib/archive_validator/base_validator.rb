# frozen_string_literal: true

class ArchiveValidator
  class BaseValidator
    include ArchiveImporter::ArchiveHelper
    attr_reader :archive_hash

    def initialize(archive_hash)
      @archive_hash = archive_hash
      validate
    end

    def messages
      @messages ||= []
    end

    def valid?
      @valid.nil? ? messages.empty? : @valid
    end

    private

    attr_writer :valid

    def validate; end
  end
end
