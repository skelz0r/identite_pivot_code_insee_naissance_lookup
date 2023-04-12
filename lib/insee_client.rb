require 'faraday'
require 'redis'

class INSEEClient
  def lookup_communes(nom_commune, annee)
    http_connection = Faraday.new do |conn|
      conn.response :raise_error
      conn.response :json
      conn.options.timeout = 30
      conn.options.open_timeout = 30
      conn.request :authorization, 'Bearer', access_token
    end

    http_connection.get(
      'https://api.insee.fr/metadonnees/V1/geo/communes',
      {
        date: "#{annee}-01-01",
        filtreNom: nom_commune,
        com: false,
      },
      {
        'Accept' => 'application/json',
      }
    ).body
  rescue Faraday::ResourceNotFound
    []
  end

  def access_token
    access_token = redis.get('insee_access_token')

    return access_token if access_token

    http_connection = Faraday.new do |conn|
      conn.response :raise_error
      conn.response :json
      conn.options.open_timeout = 10
      conn.options.timeout = 10
    end

    response = http_connection.post(
      'https://api.insee.fr/token',
      'grant_type=client_credentials',
      {
        'Authorization' => "Basic #{encoded_client_id_and_secret}",
      },
    ).body


    access_token = response['access_token']

    redis.set('insee_access_token', access_token)
    redis.expire('insee_access_token', response['expires_in'])

    access_token
  end

  private

  def encoded_client_id_and_secret
    Base64.strict_encode64("#{ENV['INSEE_CLIENT_ID']}:#{ENV['INSEE_CLIENT_SECRET']}")
  end

  def redis
    @redis ||= Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379')
  end
end
