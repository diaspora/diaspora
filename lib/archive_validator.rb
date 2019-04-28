# frozen_string_literal: true

require "yajl"

# ArchiveValidator checks for errors in archive. It also find non-critical problems and fixes them in the archive hash
# so that the ArchiveImporter doesn't have to handle this issues. Non-critical problems found are indicated as warnings.
# Also it performs necessary data fetch where required.
class ArchiveValidator
  include ArchiveImporter::ArchiveHelper

  def initialize(archive)
    @archive = archive
  end

  def validate
    run_validators(CRITICAL_VALIDATORS, errors)
    run_validators(NON_CRITICAL_VALIDATORS, warnings)
  rescue KeyError => e
    errors.push("Missing mandatory data: #{e}")
  rescue Yajl::ParseError => e
    errors.push("Bad JSON provided: #{e}")
  end

  def errors
    @errors ||= []
  end

  def warnings
    @warnings ||= []
  end

  def archive_hash
    @archive_hash ||= Yajl::Parser.new.parse(archive)
  end

  CRITICAL_VALIDATORS = [
    SchemaValidator,
    AuthorPrivateKeyValidator
  ].freeze

  NON_CRITICAL_VALIDATORS = [
    ContactsValidator,
    PostsValidator,
    RelayablesValidator,
    OthersRelayablesValidator
  ].freeze

  private_constant :CRITICAL_VALIDATORS, :NON_CRITICAL_VALIDATORS

  private

  attr_reader :archive

  def run_validators(list, messages)
    list.each do |validator_class|
      validator = validator_class.new(archive_hash)
      messages.concat(validator.messages)
    end
  end
end
