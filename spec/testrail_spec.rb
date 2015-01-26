require_relative "../lib/telly"
require_relative "../lib/testrail"
require_relative './spec_helper'


describe Telly do
  class BTModule
  end

  before :each do
    @testrail_credentials = {
      "testrail_username" => "test",
      "testrail_password" => "testpass"
    }
  end

  describe "#get_testrail_api" do
    it "returns a APIClient object" do
      api = Telly::get_testrail_api(@testrail_credentials)
      expect(api).to be_an_instance_of TestRail::APIClient
    end

    it "has the correct credentials" do
      api = Telly::get_testrail_api(@testrail_credentials)
      expect(api.password).to be @testrail_credentials["testrail_password"]
      expect(api.user).to be @testrail_credentials["testrail_username"]
    end
  end
end
