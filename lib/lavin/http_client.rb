# frozen_string_literal: true

require 'lavin/client'

module Lavin
  module HttpClient
    attr_reader :client
    attr_writer :index

    def initialize(**kwargs)
      super(**kwargs)
      @client = kwargs.fetch(:client) { Client.new(config[:base_url]) }
    end

    def cleanup
      client&.close
    end

    def get(url, headers: {})
      request(:get, url:, headers:)
    end

    def head(url, headers: {})
      request(:head, url:, headers:)
    end

    def post(url, headers: {}, body: nil)
      request(:post, url:, headers:, body:)
    end

    def put(url, headers: {}, body: nil)
      request(:put, url:, headers:, body:)
    end

    def patch(url, headers: {}, body: nil)
      request(:patch, url:, headers:, body:)
    end

    def delete(url, headers: {})
      request(:delete, url:, headers:)
    end

    private

    def request(method, url:, headers:, body: nil)
      client.request(method, url:, headers:, body:).tap do |response|
        raise ServerError, response[:status] if response[:status] > 499
      end
    end
  end
end
