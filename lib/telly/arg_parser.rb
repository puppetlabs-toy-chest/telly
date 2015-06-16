require 'optparse'

module Telly
  class ArgParser

    VERSION_STRING =
"
 __o_____
()/O\\___()
 `-\\\\---' TELLY
              %s!
      __\\/__
     | .... |
     | .... |
      ------
"

    # Parses the command line options
    # @return [Void]
    def self.parse_opts
      options_hash = {}

      optparse = OptionParser.new do|parser|
        options_hash = {
          testrun_id: nil,
          junit_file: nil,
        }

        parser.on( '-t', '--testrun-id TESTRUN_ID', 'The testrun id' ) do |testrun_id|
          options_hash[:testrun_id] = testrun_id
        end

        parser.on( '-j', '--junit-folder JUNIT_FILE', 'Beaker junit file' ) do |junit_file|
          options_hash[:junit_file] = junit_file
        end

        parser.on( '-h', '--help', 'Display this screen' ) do
          puts parser
          exit
        end

        parser.on( '-v', '--version', 'Report the current version number' ) do
          puts VERSION_STRING % Telly::Version::STRING
          exit
        end


        parser.parse!

        if not options_hash[:testrun_id] or not options_hash[:junit_file]
          puts "Error: Missing option(s)"
          puts parser
          exit
        end
      end

      options_hash
    end
  end
end
