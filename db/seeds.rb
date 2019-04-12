require "csv"


User.find_or_create_by(id: 1) do |user|
  user.email = 'info@bento.jp'
  user.password = 'password'
end
