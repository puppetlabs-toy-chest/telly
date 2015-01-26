telly
===============

The telly project is a script designed to relieve the manual effort required when setting TestRail results for automated Beaker tests

**The telly project is very much in Alpha right now, and not recommended for use**

Download
--

Soon a gem will be put on rubygems.org

For now you can package and install the gem manually with 

`gem build telly.gemspec`

`gem install telly-0.1.0.gem`


Usage
--
`telly -t 1234123121 -j beaker_tests/junit/latest/beaker_junit.xml`

Currently using the script requires a few things.

* A Beaker junit output file
* The Test Run ID from a testrail test run. This can be found in the upper left of the test run page
* Your beaker scripts must include the Test Case ID in the test_name
    * e.g. `test_name "QENG-694 - C57870 - This is a well written test name"`
    * There is a plan to remove this requirement, see the Roadmap below

The script displays output showing progress, and on completion will print any test cases that failed to submit their results to TestRail. These might be incorrect test case IDs or authentication problems. Currently there isn't a good way to retry a submission and only submit the previous failures. It simply re-submits all of the beaker results. 

Roadmap
--

Since this project is currently just a proof of concept, there is a lot that has to be done.

To make it generally usable for others, the plan is:

* Create spec tests (in progress)
* Harden the code
    * be able to properly handle failures to post individual data
    * be able to properly handle net failure part way through posting
    * error handling for bad user provided data, failures
* Release gem for testing
    * Code is all packaged up to be made into a gem, but is not on rubygems yet

After this initial release, we can potentially expand this to integrate directly with the TestRail website and jenkins to execute test runs with the click of a button and have the results fed back into testrail automatically.

TODO
--
**Automated Test Links**

In order to remove the requirement of having testcase IDs in beaker scripts, the QA team has suggested using the Automated Test Link field from TestRail to match up beaker test output to a TestRail test case.

This would involve using the [get_tests](http://docs.gurock.com/testrail-api2/reference-tests#get_tests) api call to get the tests from a test run, examining the Automated Test Link field, and matching the github links to the beaker test scripts in the junit output.

It would be harder to implement but much simpler for the user, since putting the testcase ID in the beaker script isn't universal among the QA teams

Useful Links
--
If you are hacking on this project, the [TestRail API docs](http://docs.gurock.com/testrail-api2/start) might come in handy
