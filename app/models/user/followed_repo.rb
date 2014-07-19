#TODO kill
class User::FollowedRepo
  attr_reader :data

  def initialize(data)
    @data = JSON.parse(data)
  end

  def description
    data['description']
  end

  def repo
    data['link'].gsub('https://github.com/', '')
  end

  def date
    @date ||= Date.parse(data['date'])
  end

  def link
    data['link']
  end

  def user
    User.find(data['user_id'])
  end
end
