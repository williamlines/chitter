require 'bcrypt'
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

  def time_now(time = Time.parse('2000-01-01 12:30:00'))
    return time.to_s.split(' ').first(2).join(' ')
  end

  def invalid_peep_params?
    if UserRepository.new.find_by_handle(params[:handle]) == nil
      return true
    end 
     
    params[:peep_content].each_char do |char|
      if ['<', '>', '&', '%'].include?(char)
        return true
      end
    end
    
    params[:handle].each_char do |char|
      if ['<', '>', '&', '%'].include?(char)
        return true
      end
    end
    return false 
  end

  get '/' do
    peep_repo = PeepRepository.new
    user_repo = UserRepository.new

    @peeps = peep_repo.all.sort_by{|peep| Time.parse(peep.time)}.reverse
    return erb(:index)
  end

  get '/peep/new' do
    return erb(:peep_new)
  end

  post '/peep' do
    if invalid_peep_params?
      status 400
      return ''
    end
    
    peep_repo = PeepRepository.new
    new_peep = Peep.new
    
    handle = params[:handle]
    user_id = UserRepository.new.find_by_handle(handle).id
    new_peep.content = params[:peep_content]
    new_peep.user_id = user_id
    new_peep.time = time_now

    peep_repo.create(new_peep)
    
    return erb(:peep_made)
  end

  get '/login' do
    return erb(:login)
  end

  post '/login' do
    @user = UserRepository.new.find_by_handle(params[:handle])
    if @user == nil
      return erb(:login_fail)
    elsif BCrypt::Password.new(@user.password) != params[:password]
      return erb(:login_fail)
    else
      return erb(:login_successful)
    end
  end
end