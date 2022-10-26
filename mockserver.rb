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
  end

  def response
    [status, headers, body]
  end

  private

  def status
    params.fetch('status', 200).to_i
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
