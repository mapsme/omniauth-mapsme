require 'oauth2'
require 'omniauth'
require_relative 'mapsme-base'

module OmniAuth
  module Strategies
    class MapsMeToken
      include OmniAuth::Strategy
      include OmniAuth::Strategies::MapsMeBase

      option :name, 'mapsme_token'

      args [:client_id, :client_secret]

      option :client_id, nil
      option :client_secret, nil

      option :client_options, MAPSME_CLIENT_OPTIONS

      option :access_token_options, {
        :header_format => 'OAuth %s',
        :param_name => 'access_token'
      }

      attr_accessor :access_token

      uid { raw_info['uid'].to_s }

      info do
        prune!({
          'email' => raw_info['email'],
          'name' => raw_info['name']
        })
      end

      extra do
        { :raw_info => raw_info }
      end

      credentials do
        hash = {'token' => access_token.token}
        hash.merge!('refresh_token' => access_token.refresh_token) if access_token.expires? && access_token.refresh_token
        hash.merge!('expires_at' => access_token.expires_at) if access_token.expires?
        hash.merge!('expires' => access_token.expires?)
        hash
      end

      def authorize_params
        super.tap do |params|
          params[:scope] = 'user mail'
        end
      end

      def raw_info
        @raw_info ||= access_token.get('/user').parsed || {}
      end

      def info_options
        options[:info_fields] ? {:params => {:fields => options[:info_fields]}} : {}
      end

      def client
        ::OAuth2::Client.new(options.client_id, options.client_secret, deep_symbolize(options.client_options))
      end

      def request_phase
        form = OmniAuth::Form.new(:title => "User Token", :url => callback_path)
        form.text_field "Access Token", "access_token"
        form.button "Sign In"
        form.to_response
      end

      def callback_phase
        if !request.params['access_token'] || request.params['access_token'].to_s.empty?
          raise ArgumentError.new("No access token provided.")
        end

        self.access_token = build_access_token
        self.access_token = self.access_token.refresh! if self.access_token.expired?

        # Instead of calling super, duplicate the functionality, but change the provider to 'mapsme'.
        # So the list of accounts is single for both strategies.
        hash = auth_hash
        hash[:provider] = "mapsme"
        self.env['omniauth.auth'] = hash
        call_app!

       rescue ::OAuth2::Error => e
         fail!(:invalid_credentials, e)
       rescue ::MultiJson::DecodeError => e
         fail!(:invalid_response, e)
       rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
         fail!(:timeout, e)
       rescue ::SocketError => e
         fail!(:failed_to_connect, e)
      end

      def mock_callback_call
        # Copying the parent implementation just so we can replace the provider name
        setup_phase
        @env['omniauth.origin'] = session.delete('omniauth.origin')
        @env['omniauth.origin'] = nil if env['omniauth.origin'] == ''
        mocked_auth = OmniAuth.mock_auth_for(:mapsme)
        if mocked_auth.is_a?(Symbol)
          fail!(mocked_auth)
        else
          @env['omniauth.auth'] = mocked_auth
          @env['omniauth.params'] = session.delete('omniauth.params') || {}
          OmniAuth.config.before_callback_phase.call(@env) if OmniAuth.config.before_callback_phase
          call_app!
        end
      end

      protected

      def deep_symbolize(hash)
        hash.inject({}) do |h, (k,v)|
          h[k.to_sym] = v.is_a?(Hash) ? deep_symbolize(v) : v
          h
        end
      end

      def build_access_token
        # Options supported by `::OAuth2::AccessToken#initialize` and not overridden by `access_token_options`
        hash = request.params.slice("access_token", "expires_at", "expires_in", "refresh_token")
        hash.update(options.access_token_options)
        ::OAuth2::AccessToken.from_hash(
          client,
          hash
        )
      end

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'mapsme_token', 'MapsMeToken'
