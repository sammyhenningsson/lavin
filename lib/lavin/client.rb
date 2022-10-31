# frozen_string_literal: true

require 'async/http/internet'

module Lavin
  class Client
    class Error < Lavin::Error; end
    class NoCurrentAsyncTaskError < Error
      def initialize(msg = nil)
        super(msg || "Trying to create a client outside of an Async task")
      end
    end

    DEFAULT_HEADERS = {
      'User-Agent'=> 'LavinLoadTest',
      'Accept' => '*/*',
    }.freeze

    attr_reader :internet, :base_url
    attr_accessor :request_count, :cookie, :report_statistics

    def initialize(base_url = nil)
      raise NoCurrentAsyncTaskError unless Async::Task.current?

      @internet = Async::HTTP::Internet.new
      @base_url = base_url
      @request_count = 0
      @cookie = nil
      @report_statistics = true
    end

    def close
      internet.close
    end

    def request(method, url:, headers:, body: nil)
      url, headers, body = rewrite_request(url:, headers:, body:)

      start_time = Time.now
      response = internet.send(method, url, headers, body)
      duration = Time.now - start_time

      status, headers, body = process(response)

      Statistics.register_request(method:, url:, status:, duration:) if report_statistics

      {status:, headers:, body: body}
    end

    private

    def rewrite_request(url:, headers:, body:)
      headers = DEFAULT_HEADERS.merge(headers || {})
      headers["Cookie"] = cookie if cookie

      if body.is_a? Hash
        body = JSON.dump(body)
        headers["Content-Type"] = "application/json"
      end

      url = File.join(base_url, url) if base_url && !url.start_with?(/https?:/)

      [url, headers, body]
    end

    def process(response)
      status = response.status
      headers = response.headers
      body = response.read
      save_cookie(headers)
      self.request_count += 1

      [status, headers, body]
    end

    def save_cookie(headers)
      cookie = headers['Set-Cookie'] || headers['SET-COOKIE'] || headers['set-cookie']
      self.cookie = cookie if cookie
    end
  end
end
