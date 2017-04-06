require 'omniauth-oauth2'
require_relative 'mapsme-base'

module OmniAuth
  module Strategies
    class MapsMe < OmniAuth::Strategies::OAuth2
      include OmniAuth::Strategies::MapsMeBase

      option :name, 'mapsme'

      option :client_options, MAPSME_CLIENT_OPTIONS

      uid { raw_info['username'] }

      info do
        {
          'email' => raw_info['email'],
          'name' => extract_name(raw_info)
        }
      end

      extra do
        { :raw_info => raw_info }
      end

      def authorize_params
        super.tap do |params|
          params[:scope] = MAPSME_DEFAULT_SCOPE
        end
      end

      def raw_info
        @raw_info ||= access_token.get(MAPSME_USER_DETAILS).parsed || {}
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
