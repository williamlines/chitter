require 'bcrypt'
require 'sinatra/base'
require 'sinatra/reloader'
require_relative './lib/database_connection'
require_relative './lib/peep_repository'
require_relative './lib/user_repository'


DatabaseConnection.connect('chitter_test')


class Application < Sinatra::Base

  enable :sessions

  configure :development do
    register Sinatra::Reloader
  end

  def time_now(time = Time.now)
    return time.to_s.split(' ').first(2).join(' ')
  end

  def invalid_peep_params?
    params[:peep_content].each_char do |char|
      if ['<', '>', '&', '%'].include?(char)
        return true
      end
    end
    return false 
  end

  def session_user
    if session[:user_id] == nil
      return "none, log in?"
    end
    return UserRepository.new.find(session[:user_id]).handle
  end

  get '/' do
    peep_repo = PeepRepository.new
    user_repo = UserRepository.new
    @session_user = session_user

    @peeps = peep_repo.all.sort_by{|peep| Time.parse(peep.time)}.reverse
    return erb(:index)
  end

  get '/peep/new' do
    if session[:user_id] == nil
      return redirect('/login')
    else
      return erb(:peep_new)
    end
  end

  post '/peep' do
    if invalid_peep_params?
      status 400
      return ''
    end
    
    peep_repo = PeepRepository.new
    new_peep = Peep.new

    new_peep.content = params[:peep_content]
    new_peep.user_id = session[:user_id]
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
      session[:user_id] = @user.id
      return erb(:login_successful)
    end
  end
end