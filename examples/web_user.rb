require 'lavin/user'

class WebUser < Lavin::User
  description "A user making http requests"
  user_count 1000
  iterations 10
  base_url "http://localhost:4567/"

  step(name: "create new account") do
    post("/session")
  end

  step(name: "book") do
    get("/bookings")
    post("/bookings/#{rand(100)}/confirm")
  end
end
