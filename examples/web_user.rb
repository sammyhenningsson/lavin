require 'lavin/user'

class WebUser < Lavin::User
  description "A user making http requests"
  user_count 1000
  iterations 10
  base_url "http://172.31.1.30:4567/"

  step(name: "create new account") do
    get("/session?status=201")
  end

  # step(name: "work", repeat: 3) do
  #   foo = ""
  #   1000.times do |i|
  #     100.times do |j|
  #       foo << j
  #     end
  #   end
  # end

  step(name: "book") do
    get("/bookings?status=200")
    # failure "failed to book" if rand(100) < 5
    # post("/bookings/#{rand(100)}/confirm?status=200")
  end
end
