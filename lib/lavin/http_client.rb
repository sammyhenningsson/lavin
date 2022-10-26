# frozen_string_literal: true

require 'lavin/client'

module Lavin
  module HttpClient
    attr_reader :client
    attr_writer :index

    def initialize(**kwargs)
      super(**kwargs)
      @client = Client.new(config[:base_url])
    end

    def cleanup
      client&.close
    end

    def get(url, headers: {})
      client.request(:get, url:, headers:)
    end

    def head(url, headers: {})
      client.request(:head, url:, headers:)
    end

    def post(url, headers: {}, body: nil)
      client.request(:post, url:, headers:, body:)
    end

    def put(url, headers: {}, body: nil)
      client.request(:put, url:, headers:, body:)
    end

    def patch(url, headers: {}, body: nil)
      client.request(:patch, url:, headers:, body:)
    end

    def delete(url, headers: {})
      client.request(:delete, url:, headers:)
    end
  end
end
