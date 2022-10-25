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

    def get(url, headers: DEFAULT_HEADERS)
      request(:get, url:, headers:)
    end

    def head(url, headers: DEFAULT_HEADERS)
      request(:head, url:, headers:)
    end

    def post(url, headers: DEFAULT_HEADERS, body: nil)
      request(:post, url:, headers:, body:)
    end

    def put(url, headers: DEFAULT_HEADERS, body: nil)
      request(:put, url:, headers:, body:)
    end

    def patch(url, headers: DEFAULT_HEADERS, body: nil)
      request(:patch, url:, headers:, body:)
    end

    def delete(url, headers: DEFAULT_HEADERS)
      request(:delete, url:, headers:)
    end

    private

    def request(method, url:, headers:, body: nil)
      if body.is_a? Hash
        body = JSON.dump(body)
        headers["Content-Type"] = "application/json"
      end

      url = File.join(base_url, url) if base_url && !url.start_with?(/https?:/)
      response = internet.send(method, url, headers, body)
      self.request_count += 1
      [response.status, response.headers, response.read]
    end
  end
end
