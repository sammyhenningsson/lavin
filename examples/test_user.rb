require 'lavin/user'

class TestUser < Lavin::User
  description "A user to test if things work"
  user_count 2
  iterations 3

  step do
    puts "doing some amazing stuff.."
  end

  step do
    puts "doing even more amazing stuff.."
  end
end
