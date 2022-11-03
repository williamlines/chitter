require 'database_connection'
require 'user_repository'

def reset_table
  seed_sql = File.read('spec/chitter_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'chitter_test' })
  connection.exec(seed_sql)
end

describe UserRepository do
  before(:each) do 
    reset_table
    @repo = UserRepository.new
  end
  context "all method" do
    it "can list all users" do
      users = @repo.all
      expect(users[0].id).to eq "1"
      expect(users[1].handle).to eq "bob2"
      expect(users[2].email).to eq "clara3@gmail.com"
      expect(users[2].password).to eq "password3"
    end
  end
  context "create method" do
    it "can create a new user" do 
      user = User.new
      user.handle = "dave4"
      user.email = "dave4@gmail.com"
      user.password = "password4"
      @repo.create(user)

      new_user = @repo.all[3]
      expect(new_user.handle).to eq("dave4")
      expect(new_user.password).to eq "password4"
    end
  end
  context "find method" do
    it "can find a user by their id" do
      user = @repo.find(2)
      expect(user.id).to eq '2'
      expect(user.handle).to eq 'bob2'
    end
  end
end