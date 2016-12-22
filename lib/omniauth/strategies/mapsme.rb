require 'omniauth-oauth2'
require_relative 'mapsme-base'

module OmniAuth
  module Strategies
    class MapsMe < OmniAuth::Strategies::OAuth2
      include OmniAuth::Strategies::MapsMeBase

      option :name, 'mapsme'

      option :client_options, MAPSME_CLIENT_OPTIONS

      uid { raw_info['uid'].to_s }

      info do
        {
          'email' => raw_info['email'],
          'name' => raw_info['name']
        }
      end

      extra do
        { :raw_info => raw_info }
      end

      def authorize_params
        super.tap do |params|
          params[:scope] = 'user mail'
        end
      end

      def raw_info
        @raw_info ||= access_token.get('/user').parsed || {}
      end

      # Fix omniauth-oauth2 issue https://github.com/intridea/omniauth-oauth2/issues/76

      def build_access_token
        options.token_params.merge!(:headers => {'Authorization' => basic_auth_header })
        super
      end

      def basic_auth_header
        "Basic " + Base64.strict_encode64("#{options[:client_id]}:#{options[:client_secret]}")
      end

      # Fix omniauth-oauth2 issue https://github.com/intridea/omniauth-oauth2/issues/93

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end

OmniAuth.config.add_camelization 'mapsme', 'MapsMe'
