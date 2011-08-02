require 'capistrano/recipes/deploy/scm/base'
require 'rexml/xpath'
require 'rexml/document'

module Capistrano
  module Deploy
    module SCM
      # Accurev bridge for use by Capistrano. This implementation does not
      # implement all features of a Capistrano SCM module. The ones that are
      # left out are either exceedingly difficult to implement with Accurev
      # or are considered bad form.
      #
      # When using this module in a project, the following variables are used:
      #  * :repository - This should match the depot that code lives in. If your code
      #                  exists in a subdirectory, you can append the path depot.
      #                  eg. foo-depot/bar_dir
      #  * :stream - The stream in the depot that code should be pulled from. If 
      #              left blank, the depot stream will be used
      #  * :revision - Should be in the form 'stream/transaction'. 
      class Accurev < Base
        include REXML
        default_command 'accurev'

        # Defines pseudo-revision value for the most recent changes to be deployed.
        def head
          "#{stream}/highest"
        end

        # Given an Accurev revision identifier, this method returns an identifier that
        # can be used for later SCM calls. This returned identifier will not
        # change as a result of further SCM activity.
        def query_revision(revision)
          internal_revision = InternalRevision.parse(revision)
          return revision unless internal_revision.psuedo_revision?

          logger.debug("Querying for real revision for #{internal_revision}")
          rev_stream = internal_revision.stream

          logger.debug("Determining what type of stream #{rev_stream} is...")
          stream_xml = yield show_streams_for(rev_stream)
          stream_doc = Document.new(stream_xml)
          type = XPath.first(stream_doc, '//streams/stream/@type').value

          case type
          when 'snapshot'
            InternalRevision.new(rev_stream, 'highest').to_s
          else
            logger.debug("Getting latest transaction id in #{rev_stream}")
            # Doing another yield for a second Accurev call. Hopefully this is ok.
            hist_xml = yield scm(:hist, '-ftx', '-s', rev_stream, '-t', 'now.1')
            hist_doc = Document.new(hist_xml)
            transaction_id = XPath.first(hist_doc, '//AcResponse/transaction/@id').value
            InternalRevision.new(stream, transaction_id).to_s
          end
        end

        # Pops a copy of the code for the specified Accurev revision identifier. 
        # The revision identifier is represented as a stream & transaction ID combo.
        # Accurev can only pop a particular transaction if a stream is created on the server
        # with a time basis of that transaction id. Therefore, we will create a stream with 
        # the required criteria and pop that.
        def export(revision_id, destination)
          revision = InternalRevision.parse(revision_id)
          logger.debug("Exporting #{revision.stream}/#{revision.transaction_id} to #{destination}")

          commands = [
            change_or_create_stream("#{revision.stream}-capistrano-deploy", revision),
            "mkdir -p #{destination}",
            scm_quiet(:pop, "-Rv #{stream}", "-L #{destination}", "'/./#{subdir}'")
          ]
          if subdir
            commands.push(
              "mv #{destination}/#{subdir}/* #{destination}",
              "rm -rf #{File.join(destination, subdir)}"
            )
          end
          commands.join(' && ')
        end

        # Returns the command needed to show the changes that exist between the two revisions.
        def log(from, to=head)
          logger.info("Getting transactions between #{from} and #{to}")
          from_rev = InternalRevision.parse(from)
          to_rev = InternalRevision.parse(to)

          [
            scm(:hist, '-s', from_rev.stream, '-t', "#{to_rev.transaction_id}-#{from_rev.transaction_id}"),
            "sed -e '/transaction #{from_rev.transaction_id}/ { Q }'"
          ].join(' | ')
        end

        # Returns the command needed to show the diff between what is deployed and what is 
        # pending. Because Accurev can not do this task without creating some streams,
        # two time basis streams will be created for the purposes of doing the diff.
        def diff(from, to=head)
          from = InternalRevision.parse(from)
          to = InternalRevision.parse(to)

          from_stream = "#{from.stream}-capistrano-diff-from"
          to_stream = "#{to.stream}-capistrano-diff-to"

          [
            change_or_create_stream(from_stream, from),
            change_or_create_stream(to_stream, to),
            scm(:diff, '-v', from_stream, '-V', to_stream, '-a')
          ].join(' && ')
        end

        private
        def depot
          repository.split('/')[0]
        end

        def stream
          variable(:stream) || depot
        end

        def subdir
          repository.split('/')[1..-1].join('/') unless repository.index('/').nil?
        end

        def change_or_create_stream(name, revision)
          [
            scm_quiet(:mkstream, '-b', revision.stream, '-s', name, '-t', revision.transaction_id),
            scm_quiet(:chstream, '-b', revision.stream, '-s', name, '-t', revision.transaction_id)
          ].join('; ')
        end

        def show_streams_for(stream)
          scm :show, '-fx', '-s', stream, :streams
        end

        def scm_quiet(*args)
          scm(*args) + (variable(:scm_verbose) ? '' : '&> /dev/null')
        end

        class InternalRevision
          attr_reader :stream, :transaction_id

          def self.parse(string)
            match = /([^\/]+)(\/(.+)){0,1}/.match(string)
            raise "Unrecognized revision identifier: #{string}" unless match

            stream = match[1]
            transaction_id = match[3] || 'highest'
            InternalRevision.new(stream, transaction_id)
          end

          def initialize(stream, transaction_id)
            @stream = stream
            @transaction_id = transaction_id
          end

          def psuedo_revision?
            @transaction_id == 'highest'
          end

          def to_s
            "#{stream}/#{transaction_id}" 
          end

          def ==(other)
            (stream == other.stream) && (transaction_id == other.transaction_id)
          end
        end
      end
    end
  end
end
