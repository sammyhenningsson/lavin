# frozen_string_literal: true

require 'sinatra/base'
require 'lavin/user'
require 'lavin/statistics'

module Lavin
  class WebServer < Sinatra::Base
    set :views, File.expand_path("../../views", __dir__)
    set :port, 1080

    not_found do
      erb :not_found, status: 404
    end

    error do
      erb :server_error, status: 500, locals: {error: env['sinatra.error']}
    end

    helpers do
      def input_type_for(value)
        case value
        when Numeric
          "number"
        when TrueClass, FalseClass
          "checkbox"
        else
          "text"
        end
      end
    end

    get '/' do
      erb :index, locals: { personas: Lavin::User.all_personas }
    end

    post '/start' do
      Statistics.reset
      Lavin::Runner.start_async
      redirect to('/statistics')
    end

    get '/statistics' do
      puts "GET /statistics"
      stats = Statistics.stats
      running = Lavin::Runner.running?
      if stats.empty? && !running
        redirect to('/')
      else
        erb :statistics, locals: {stats:, running:}
      end
    end

    get '/edit' do
      persona = find_persona
      raise Sinatra::NotFound unless persona

      erb :edit, locals: {persona:}
    end

    post '/update_config' do
      persona = find_persona
      raise Sinatra::NotFound unless persona

      persona.config.each do |key, old_value|
        bool = [true, false].include? old_value
        next unless bool || params.key?(key.to_s)

        new_value = rewrite_config_value(params[key.to_s], old_value)
        persona.send(key, new_value)
      end

      redirect to('/')
    end

    def find_persona(name = nil)
      name ||= params['persona']
      Lavin::User.all_personas.find do |persona|
        persona.name == name
      end
    end

    def rewrite_config_value(new_value, old_value)
      case old_value
      when TrueClass, FalseClass
        !!new_value
      when Integer
        new_value.to_i
      when Float
        new_value.to_f
      else
        new_value.to_s
      end
    end
  end
end
