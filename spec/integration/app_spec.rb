require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_table
  seed_sql = File.read('spec/chitter_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'chitter_test' })
  connection.exec(seed_sql)
end

describe Application do
  include Rack::Test::Methods
  let(:app) { Application.new }
  before(:each) do 
    reset_table
  end
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
    it "shows new peeps first" do
      response = get('/')
      expect(response.body).to include '            clara3<br>
            claras first peep<br>
            2022-11-03 at 15:55:00<br>
          
            <br>
            
            
            bob2<br>
            bobs second peep<br>
            2022-11-03 at 04:00:00<br>'
    end
  end
  
  context "get to '/peep/new'" do
    it "responds 200 OK" do
      response = get('/peep/new')
      expect(response.status).to eq 200
    end
    it "displays a form to make a new peep" do
      response = get('peep/new')
      expect(response.body).to include('<form action="/peep" method="POST">')
      expect(response.body).to include('<input type="text" name="handle"')
      expect(response.body).to include('<input type="text" name="peep_content"')
      expect(response.body).to include('<input type="submit" value="Peep!"')
    end
  end

  context "post to '/peep'" do
    it "can make a new peep" do
      response = post(
        '/peep',
        handle: 'clara3',
        peep_content: 'this is a new test peep'
      )
      time = double(:time)
      allow(time).to receive(:time_now).and_return(Time.parse('2000-01-01 12:30'))
      expect(response.status).to eq 200
      expect(response.body).to include('Peep has been made!')

      expect(get('/').body).to include('this is a new test peep')
      expect(get('/').body).to include('2000-01-01 at 12:30:00')
    end
    it "tests for valid arguments" do
      response = post(
        '/peep',
        handle: 'garry',
        peep_content: 'this is a new test peep'
      )
      expect(response.status).to be 400
      expect(response.body).to eq ''
    end
    it "tests for special characters in content" do
      response = post(
        '/peep',
        handle: 'clara3',
        peep_content: '<script> bad stuff </script>'
      )
      expect(response.status).to be 400
      expect(response.body).to eq ''
    end
    it "tests for special characters in handle" do
      response = post(
        '/peep',
        handle: '<script>',
        peep_content: 'valid'
      )
      expect(response.status).to be 400
      expect(response.body).to eq ''
    end
  end
end