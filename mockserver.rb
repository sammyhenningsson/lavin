#!/usr/bin/env ruby

require 'sinatra'

class Mock
  attr_reader :request, :params

  def initialize(request, params)
    @request = request
    @params = params
  end

  def log(method)
    puts "#{method} #{request.path_info} #{params.inspect}"
    puts "Accept: #{request.env["HTTP_ACCEPT"]}"
  end

  def response
    sleep(params["sleep"].to_f) if params["sleep"]
    [status, headers, body]
  end

  private

  def status
    provided = params['status']
    return given.to_i if provided

    if rand(100) < 5
      [500, 502, 503, 504].sample
    else
      200
    end
  end

  def headers
    {}.tap do |headers|
      headers['Location'] = '/redirect_url' if redirect?
      headers['Content-Type'] = 'text/plain' if body.size.positive?
    end
  end

  def redirect?
    [301, 302, 303, 307, 308].include? status
  end

  def body
    @body ||= request.body.read
  end
end

%i[get post put patch delete head].each do |method|
  send(method, /.*/) do
    mock = Mock.new(request, params)
    mock.log(method.to_s.upcase)
    mock.response
  end
end
