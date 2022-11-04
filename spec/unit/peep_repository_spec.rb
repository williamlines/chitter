require 'database_connection'
require 'peep_repository'

def reset_table
  seed_sql = File.read('spec/chitter_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'chitter_test' })
  connection.exec(seed_sql)
end

describe PeepRepository do
  before(:each) do 
    reset_table
    @repo = PeepRepository.new
  end
  context "all method" do
    it "can list all peeps" do
      peeps = @repo.all

      expect(peeps[0].content).to eq "adams first peep"
      expect(peeps[1].time).to eq "2022-11-02 12:30:00"
      expect(peeps[4].user_id).to eq "3"
    end
  end
  context "create method" do
    it "can create a new peep" do
      peep = Peep.new
      peep.content = "test peep"
      peep.time = "2000-01-01 12:00:00"
      peep.user_id = "3"

      @repo.create(peep)
      new_peep = @repo.all[-1]

      expect(new_peep.content).to eq "test peep"
      expect(new_peep.time).to eq "2000-01-01 12:00:00"
      expect(new_peep.user_id).to eq "3"
    end
  end
end