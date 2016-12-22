module OmniAuth
  module Strategies
    module MapsMeBase
      MAPSME_BASE = 'http://passport.maps.me'

      MAPSME_CLIENT_OPTIONS = {
        :site => MAPSME_BASE,
        :authorize_url => "#{MAPSME_BASE}/oauth/authorize",
        :token_url => "#{MAPSME_BASE}/oauth/token"
      }
    end
  end
end
