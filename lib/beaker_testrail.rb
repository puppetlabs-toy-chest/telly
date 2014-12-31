#!/usr/bin/env ruby

require 'nokogiri'
require 'yaml'
require 'pp'
require 'testrail'

# == beaker_testrail.rb
# This module provides functions to add test results in testrail from a 
# finished beaker run. 
# 
# It takes in a beaker junit file and a TestRail Testrun ID
# 
# It matches the beaker tests with TestRail testcases by looking for the 
#   test case ID in the beaker script. The combination of a test run and a test case
#   allows the script to add a result for a particular instance of a test case.
#   In TestRail parlance, this is confusingly called a test.
# From the TestRail API docs:
#   "In TestRail, tests are part of a test run and the test cases are part of the
#   related test suite. So, when you create a new test run, TestRail creates a test
#   for each test case found in the test suite of the run. You can therefore think
#   of a test as an “instance” of a test case which can have test results, comments 
#   and a test status.""
module BeakerTestrail

  TESTRAIL_URL = 'https://testrail.ops.puppetlabs.net/'
  CREDENTIALS_FILE = '~/.testrail_credentials.yaml'

  # Used for extracted the test case ID from beaker scripts
  TESTCASE_ID_REGEX = /.*(?<jira_ticket>\w+-\d+).*[cC](?<testrun_id>\d+)/

  # Testrail Status IDs
  PASSED = 1
  BLOCKED = 2
  FAILED = 5

  def do_stub_test(credentials)
    api = get_testrail_api(credentials)

    api.send_post
  end


  ##################################
  # Main
  ##################################

  # Run the importer
  # 
  # @param [Hash] An optparse object
  #
  # @return [Void]
  #
  # @example password = BeakerTestrail::main(parse_opts)
  def BeakerTestrail.main(options)
    # Get pass/fail/skips from junit file
    results = load_junit_results(options[:junit_file])

    puts "Run results:"
    puts "#{results[:passes].length} Passing"
    puts "#{results[:failures].length} Failing or Erroring"
    puts "#{results[:skips].length} Skipped"

    # Set results in testrail
    bad_results = set_testrail_results(results, options[:junit_file], options[:testrun_id])

    # Print error messages
    if not bad_results.empty?
      puts "Error: There were problems processing these test scripts:"
      bad_results.each do |test_script, error|
        puts "#{test_script}:\n\t#{error}"
      end
    end
  end


  ##################################
  # TestRail API
  ##################################

  # Load testrail credentials from file
  #
  # @return [Hash] Contains testrail_username and testrail_password
  #
  # @example password = load_credentials()["testrail_password"]
  def BeakerTestrail.load_credentials(credentials_file)
    begin
      YAML.load_file(File.expand_path(credentials_file))  
    rescue
      puts "Error: Could not find #{credentials_file}"
      puts "Create #{credentials_file} with the following:"
      puts "testrail_username: your.username\ntestrail_password: yourpassword"

      exit
      
    end
  end


  # Returns a testrail API object that talks to testrail
  # 
  # @param [Hash] credentials A hash containing at least two keys, testrail_username and testrail_password
  #
  # @return [TestRail::APIClient] The API object for talking to TestRail
  #
  # @example api = get_testrail_api(load_credentials)
  def BeakerTestrail.get_testrail_api(credentials)
    client = TestRail::APIClient.new(TESTRAIL_URL)
    client.user = credentials["testrail_username"]
    client.password = credentials["testrail_password"]

    return client
  end

  # Sets the results in testrail. 
  # Tests that have testrail API exceptions are kept track of in bad_results
  #
  # @param [Hash] results A hash of lists of xml objects from the junit output file.
  # @param [String] junit_file The path to the junit xml file
  #                 Needed for determining the path of the test file in add_failure, etc
  # @param [String] testrun_id The TestRail test run ID
  # 
  # @return [Void] 
  #
  def BeakerTestrail.set_testrail_results(results, junit_file, testrun_id)
    credentials = load_credentials(CREDENTIALS_FILE)
    api = get_testrail_api(credentials)

    # Results that couldn't be set in testrail for some reason
    bad_results = {}

    # passes
    results[:passes].each do |junit_result|
      begin
        submit_result(api, PASSED, junit_result, junit_file, testrun_id)    
      rescue TestRail::APIError => e
        bad_results[junit_result[:name]] = e.message
      end
    end

    # Failures
    results[:failures].each do |junit_result|
      begin
        submit_result(api, FAILED, junit_result, junit_file, testrun_id)    
      rescue TestRail::APIError => e
        bad_results[junit_result[:name]] = e.message
      end
    end

    # Skips
    results[:skips].each do |junit_result|
      begin
        submit_result(api, BLOCKED, junit_result, junit_file, testrun_id)    
      rescue TestRail::APIError => e
        bad_results[junit_result[:name]] = e.message
      end
    end

    return bad_results
  end

  # Submits a test result to TestRail
  #
  # @param [TestRail::APIClient] api TestRail API object
  # @param [int] status The testrail status to set
  # @param [Nokogiri::XML::Element] junit_result The nokogiri node that holds the junit result
  # @param [String] junit_file Path to the junit file the test result originated from
  # @param [String] testrun_id The testrun ID
  #
  # @return [Void]
  # 
  # @raise [TestRail::APIError] When there is a problem with the API request, testrail raises
  #                             this exception. Should be caught for error reporting
  #
  # @example submit_result(api, BLOCKED, junit_result, junit_file, testrun_id)
  def BeakerTestrail.submit_result(api, status, junit_result, junit_file, testrun_id)
    test_file_path = beaker_test_path(junit_file, junit_result)

    puts junit_result.class
    testcase_id = testcase_id_from_beaker_script(test_file_path)

    time_elapsed = make_testrail_time(junit_result[:time])

    # Make appropriate comment for testrail
    case status
    when FAILED
      error_message = junit_result.xpath('./failure').first[:message]
      testrail_comment = "Failed with message:\n#{error_message}"
    when BLOCKED
      skip_message = junit_result.xpath('system-out').first.text
      testrail_comment = "Skipped with message:\n#{skip_message}"
    else
      testrail_comment = "Passed"
    end

    puts "\nSetting result for test case: #{testcase_id}"
    puts "Adding comment:\n#{testrail_comment}"

    api.send_post("add_result_for_case/#{testrun_id}/#{testcase_id}", 
      {
        status_id: status,
        comment: testrail_comment,
        elapsed: time_elapsed,
      }
    )
  end


  # Returns a string that testrail accepts as an elapsed time
  # Input from beaker is a float in seconds, so it rounds it to the 
  # nearest second, and adds an 's' at the end
  # 
  # Testrail throws an exception if it gets "0s", so it returns a 
  # minimum of "1s"
  #
  # @param [String] seconds_string A string that contains only a number, the elapsed time of a test
  #
  # @return [String] The elapsed time of the test run, rounded and with an 's' appended
  #
  # @example puts make_testrail_time("2.34") # "2s"
  def BeakerTestrail.make_testrail_time(seconds_string)
    # If time is 0, make it 1
    rounded_time = [seconds_string.to_f.round, 1].max
    # Test duration
    time_elapsed = "#{rounded_time}s"

    return time_elapsed
  end


  ##################################
  # Junit and Beaker file functions
  ##################################

  # Loads the results of a beaker run.
  # Returns hash of failures, passes, and skips that each hold a list of 
  # junit xml objects
  #
  # @param [String] junit_file Path to a junit xml file
  # 
  # @return [Hash] A hash containing xml objects for the failures, skips, and passes
  #
  # @example load_junit_results("~/junit/latest/beaker_junit.xml")
  def BeakerTestrail.load_junit_results(junit_file)
    junit_doc = Nokogiri::XML(File.read(junit_file))

    failures = junit_doc.xpath('//testcase[failure]')
    skips = junit_doc.xpath('//testcase[skip]')
    passes = junit_doc.xpath('//testcase[not(failure) and not(skip)]')

    return {failures: failures, skips: skips, passes: passes}
  end


  # Extracts the test case id from the test script
  #
  # @param [String] beaker_file Path to a beaker test script
  # 
  # @return [String] The test case ID
  #
  # @example testcase_id_from_beaker_script("~/tests/test_the_things.rb") # 1234
  def BeakerTestrail.testcase_id_from_beaker_script(beaker_file)
    # Find first matching line
    match = File.readlines(beaker_file).map { |line| line.match(TESTCASE_ID_REGEX) }.compact.first

    match[:testrun_id]
  end


  # Calculates the path to a beaker test file by combining the junit file path
  # with the test name from the junit results.
  # Makes the assumption that junit folder that beaker creates will always be 
  # 2 directories up from the beaker script base directory.
  # TODO somewhat hacky, maybe a config/command line option
  #
  # @param [String] junit_file_path Path to a junit xml file
  # @param [String] junit_result Path to a junit xml file
  # 
  # @return [String] The path to the beaker script from the junit test result
  #
  # @example load_junit_results("~/junit/latest/beaker_junit.xml")
  def BeakerTestrail.beaker_test_path(junit_file_path, junit_result)
    beaker_folder_path = junit_result[:classname]
    test_filename = junit_result[:name]

    File.join(File.dirname(junit_file_path), "../../", beaker_folder_path, test_filename)
  end

end
