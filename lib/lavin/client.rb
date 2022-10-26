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
    attr_accessor :request_count

    def initialize(base_url = nil)
      raise NoCurrentAsyncTaskError unless Async::Task.current?

      @internet = Async::HTTP::Internet.new
      @base_url = base_url
      @request_count = 0
    end

    def close
      internet.close
    end

    def request(method, url:, headers:, body: nil)
      headers = DEFAULT_HEADERS.merge(headers || {})
      if body.is_a? Hash
        body = JSON.dump(body)
        headers["Content-Type"] = "application/json"
      end

      url = File.join(base_url, url) if base_url && !url.start_with?(/https?:/)
      start_time = Time.now
      response = internet.send(method, url, headers, body)
      duration = Time.now - start_time
      status = response.status
      headers = response.headers
      body = response.read
      self.request_count += 1
      Statistics.register_request(method:, url:, status:, duration:)

      {status:, headers:, body: body}
    end
  end
end
