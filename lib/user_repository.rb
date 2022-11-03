require_relative './user'

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

  def create(user)
    sql = 'INSERT INTO users (handle, email, password) VALUES ($1, $2, $3);'
    params = [user.handle, user.email, user.password]

    DatabaseConnection.exec_params(sql, params)
    return nil
  end
end