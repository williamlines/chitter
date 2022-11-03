require "spec_helper"
require "rack/test"
require_relative '../../app'

describe Application do
  include Rack::Test::Methods
  let(:app) { Application.new }

  context "get to '/'" do
    it "returns 200 OK and some html" do
      response = get('/')
      expect(response.status).to eq 200
      expect(response.body).to include '<html>'
    end
    it "can list all peeps" do
      response = get('/')
      expect(response.body).to include 'adams first peep'
      expect(response.body).to include 'adam1'
      expect(response.body).to include '2022-11-02 at 12:00:00'

      expect(response.body).to include 'claras first peep'
    end
  end
end