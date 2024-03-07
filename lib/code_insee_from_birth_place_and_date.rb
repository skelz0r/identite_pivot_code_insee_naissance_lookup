require './lib/insee_client'

class CodeINSEEForBirthDateAndPlace
  attr_reader :nom_commune, :annee_naissance, :departement_commune

  def initialize(nom_commune, annee_naissance, departement_commune)
    @nom_commune = nom_commune
    @annee_naissance = annee_naissance
    @departement_commune = departement_commune
  end

  def perform
    if communes_from_year.length == 1
      [200, { code_insee: communes_from_year.first['code'] }]
    elsif communes_from_year.length > 1
      valid_commune = communes_from_year.detect { |commune| commune['code'].start_with?(departement_commune) }

      [200, { code_insee: valid_commune['code'] }]
    else
      [404, { error: 'Commune non trouvée' }]
    end
  end

  private

  def communes_from_year
    @communes_from_year ||= INSEEClient.new.lookup_communes(nom_commune, annee_naissance)
  end
end
