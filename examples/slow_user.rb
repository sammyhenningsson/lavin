require 'lavin/user'

class SlowUser < Lavin::User
  description "A user taking some random naps in between making requests"
  user_count 5
  iterations 3
  base_url "http://localhost:4567/"

  step do
    sleep(rand(10) / 10.0)
    get("#{name}/waking_up/1")
    sleep(rand(10) / 10.0)
    get("#{name}/waking_up/2")
    sleep(rand(10) / 10.0)
    get("#{name}/waking_up/3")
  end
end
