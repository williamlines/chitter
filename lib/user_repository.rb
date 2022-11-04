require_relative './user'
require 'bcrypt'
class UserRepository
  def all
    sql = 'SELECT id, handle, email, password FROM users;'

    result_set = DatabaseConnection.exec_params(sql, [])
    users = []

    result_set.each do |record|
      user = User.new
      user.id = record["id"]
      user.handle = record["handle"]
      user.email = record["email"]
      user.password = record["password"]

      users << user
    end
    return users
  end
  def find(id)
    sql = 'SELECT id, handle, email, password FROM users WHERE id = $1'
    params = [id]

    result = DatabaseConnection.exec_params(sql, params)
    user = User.new
    user.id = result[0]["id"]
    user.handle = result[0]["handle"]
    user.email = result[0]["email"]
    user.password = result[0]["password"]

    return user
  end

  def find_by_handle(handle)
    sql = 'SELECT id, handle, email, password FROM users WHERE handle = $1'
    params = [handle]

    result = DatabaseConnection.exec_params(sql, params)
    user = User.new
    
    if result.num_tuples.zero?
      return nil
    end

    user.id = result[0]["id"]
    user.handle = result[0]["handle"]
    user.email = result[0]["email"]
    user.password = result[0]["password"]

    return user
  end

  def create(user)
    sql = 'INSERT INTO users (handle, email, password) VALUES ($1, $2, $3);'
    encrypted_password = BCrypt::Password.create(user.password)
    params = [user.handle, user.email, encrypted_password]

    DatabaseConnection.exec_params(sql, params)
    return nil
  end
end