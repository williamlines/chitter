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
    it "shows if you are logged in" do
      post(
        '/login',
        handle: 'clara3',
        password: 'password3'
      )
      response = get('/')
      expect(response.body).to include "Logged in as clara3"
    end
    it "shows if you are not logged in" do
      response = get('/')
      expect(response.body).to include "Logged in as none, log in?"
    end
    it "can list all peeps" do
      response = get('/')
      expect(response.body).to include 'adams first peep'
      expect(response.body).to include 'adam1'
      expect(response.body).to include '2022-11-02 at 12:00:00'

      expect(response.body).to include 'claras first peep'
      expect(response.body).to include '<h3><a href="/login">Log in</a></h3>'
      expect(response.body).to include '<a href="/peep/new">New Peep</a>'
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
    it "redirects to login if no session id" do
      response = get('/peep/new')
      expect(response.status).to eq 302
    end
    it "displays a form to make a new peep when logged in" do
      post(
        '/login',
        handle: 'clara3',
        password: 'password3'
      )
      response = get('peep/new')
      expect(response.body).to include('<form action="/peep" method="POST">')
      expect(response.body).to include('<input type="text" name="peep_content"')
      expect(response.body).to include('<input type="submit" value="Peep!"')
    end
  end

  context "post to '/peep'" do
    it "can make a new peep" do
      post(
        '/login',
        handle: 'clara3',
        password: 'password3'
      )
      response = post(
        '/peep',
        peep_content: 'this is a new test peep'
      )
      expect(response.status).to eq 200
      expect(response.body).to include('Peep has been made!')

      expect(get('/').body).to include('this is a new test peep')
    end
    it "tests for special characters in content" do
      response = post(
        '/peep',
        peep_content: '<script> bad stuff </script>'
      )
      expect(response.status).to be 400
      expect(response.body).to eq ''
    end
  end
  context "log in a user" do
    it "can show login page" do
      response = get ('/login')
      expect(response.status).to eq 200
      expect(response.body).to include('<form action="/login" method="POST">')
      expect(response.body).to include('<input type="text" name="handle">')
      expect(response.body).to include('<input type="password" name="password">')
    end

    it "can log in a user" do
      response = post(
        '/login',
        handle: 'clara3',
        password: 'password3'
      )
      expect(response.status).to eq 200
      expect(response.body).to include('Welcome Back clara3!')
    end
    it "returns fail message if password is incorrect" do
      response = post(
        '/login',
        handle: 'clara3',
        password: 'wrongpassword'
      )
      expect(response.body).to include('Incorrect handle or password')
    end
    it "returns fail message if username is incorrect" do
      response = post(
        '/login',
        handle: 'bkjbnkj',
        password: 'password3'
      )
      expect(response.body).to include('Incorrect handle or password')
    end
  end
end