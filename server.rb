require 'cuba'
require 'json'
require './lib/code_insee_from_birth_place_and_date'

Cuba.define do
  on get do
    on root do
      on param('nom_commune'), param('annee_naissance'), param('departement_commune') do |nom_commune, annee_naissance, departement_commune|
        status, payload = CodeINSEEForBirthDateAndPlace.new(nom_commune, annee_naissance, departement_commune).perform

        res.status = status
        res.write payload.to_json
      end

      on true do
        res.write File.read('pages/index.html')
      end
    end
  end
end
