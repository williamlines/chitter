require 'sinatra/base'
require 'sinatra/reloader'
require_relative './lib/database_connection'
require_relative './lib/peep_repository'
require_relative './lib/user_repository'


DatabaseConnection.connect('chitter_test')


class Application < Sinatra::Base
  # This allows the app code to refresh
  # without having to restart the server.
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    peep_repo = PeepRepository.new
    user_repo = UserRepository.new

    @peeps = peep_repo.all
    return erb(:index)
  end
end