require 'lavin/user'

class WebUser < Lavin::User
  description "User making http requests"
  user_count 10
  iterations 10
  base_url "http://localhost:4567/"

  step do
    get("#{resource}/step1")
    get("#{resource}/step1")
  end

  step do
    get("#{resource}/step2")
    get("#{resource}/step2")
  end

  def resource
    @resource ||= user_name.tr('#', '_')
  end
end
