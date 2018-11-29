require 'faraday_middleware'

module Binance
  module Client
    class REST
      def public_client(adapter)
        Faraday.new(url: "#{BASE_URL}/api") do |conn|
          conn.request :json
          conn.response :json, content_type: /\bjson$/
          conn.adapter adapter
          conn.proxy = faraday_proxy_uri if faraday_proxy_uri
        end
      end

      def verified_client(api_key, adapter)
        Faraday.new(url: "#{BASE_URL}/api") do |conn|
          conn.response :json, content_type: /\bjson$/
          conn.headers['X-MBX-APIKEY'] = api_key
          conn.adapter adapter
          conn.proxy = faraday_proxy_uri if faraday_proxy_uri
        end
      end

      def signed_client(api_key, secret_key, adapter)
        Faraday.new(url: "#{BASE_URL}/api") do |conn|
          conn.request :json
          conn.response :json, content_type: /\bjson$/
          conn.headers['X-MBX-APIKEY'] = api_key
          conn.use TimestampRequestMiddleware
          conn.use SignRequestMiddleware, secret_key
          conn.adapter adapter
          conn.proxy = faraday_proxy_uri if faraday_proxy_uri
        end
      end

      def public_withdraw_client(adapter)
        Faraday.new(url: "#{BASE_URL}/wapi") do |conn|
          conn.request :json
          conn.response :json, content_type: /\bjson$/
          conn.adapter adapter
        end
      end

      def withdraw_client(api_key, secret_key, adapter)
        Faraday.new(url: "#{BASE_URL}/wapi") do |conn|
          conn.request :url_encoded
          conn.response :json, content_type: /\bjson$/
          conn.headers['X-MBX-APIKEY'] = api_key
          conn.use TimestampRequestMiddleware
          conn.use SignRequestMiddleware, secret_key
          conn.adapter adapter
        end
      end

      def faraday_proxy_uri
        if Rails.env.development? || Rails.env.test?
          nil
        else
          ip = Rails.application.secrets[:load_balancer_ip]
          port = Rails.application.secrets[:load_balancer_port]
          ip && port ? "http://#{ip}:#{port}" : nil
        end
      end

    end
  end
end