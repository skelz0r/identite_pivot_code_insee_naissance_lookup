require './lib/code_insee_from_birth_place_and_date'
require 'csv'
require 'json'

RSpec.describe CodeINSEEForBirthDateAndPlace do
  before do
    Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/7').flushdb
  end

  CSV.foreach('./spec/examples.csv', headers: true) do |csv|
    hexhash = Digest::SHA256.hexdigest(csv.to_h.slice('nom_commune_de_naissance', 'annee_naissance', 'departement_commune_naissance', 'code_insee').to_json)[0..6]

    it "works for (#{csv['nom_commune_de_naissance']}, #{csv['annee_naissance']}, #{csv['departement_commune_naissance']}): #{csv['notes']}", vcr: { cassette_name: "#{hexhash}-#{csv['code_insee']}", record: :new_episodes } do
      status, payload = CodeINSEEForBirthDateAndPlace.new(csv['nom_commune_de_naissance'], csv['annee_naissance'], csv['departement_commune_naissance']).perform

      expect(status).to eq(200)
      expect(payload[:code_insee]).to eq(csv['code_insee'])
    end
  end
end
