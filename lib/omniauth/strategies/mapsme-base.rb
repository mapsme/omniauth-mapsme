module OmniAuth
  module Strategies
    module MapsMeBase
      MAPSME_BASE = 'https://passport.maps.me'
      MAPSME_DEFAULT_SCOPE = 'read'
      MAPSME_USER_DETAILS = '/user_details/'

      MAPSME_CLIENT_OPTIONS = {
        :site => MAPSME_BASE,
        :authorize_url => "#{MAPSME_BASE}/oauth/authorize",
        :token_url => "#{MAPSME_BASE}/oauth/token/"
      }

      def extract_name(raw_info)
        first_name = raw_info['first_name']
        last_name = raw_info['last_name']
        username = raw_info['username']

        if first_name
          if last_name
            "#{first_name} #{last_name}"
          else
            first_name
          end
        else
          username
        end
      end
    end
  end
end
