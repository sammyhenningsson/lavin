require 'lavin/user'

class WebUser < Lavin::User
  description "User making http requests"
  user_count 1000
  iterations 10
  base_url "http://localhost:4567/"

  step do
    get("#{name}/step1")
  end

  step do
    get("#{name}/step2")
  end
end
