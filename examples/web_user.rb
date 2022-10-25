require 'lavin/user'

class WebUser < Lavin::User
  description "User making http requests"
  user_count 100
  iterations 10
  base_url "http://localhost:4567/"

  step do
    @resource = user_name.tr('#', '_')
    client.get("#{@resource}/step1?request=#{client.request_count}")
    client.get("#{@resource}/step1?request=#{client.request_count}")
  end

  step do
    client.get("#{@resource}/step2?request=#{client.request_count}")
    client.get("#{@resource}/step2?request=#{client.request_count}")
  end
end
