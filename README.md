# Lookup du code INSEE de la commune de naissance en fonction d'infos d'identité

Cette webapp permet à l'aide d'un triplet d'informations d'identité de retrouver
le code INSEE de la commune de naissance d'un utilisateur.

Le triplet est le suivant:

1. `nom commune`, `string`, nom de la commune de naissance
2. `annee de naissance`, `string`, année (format YYYY) de naissance de l'usager
3. `code departement de naissance`, `string`, code (format NN) insee du
   département de naissance

A l'aide de ces 3 infos, l'API renvoie le code insee de la commune.

## Requirements

- ruby 3.1.2
- redis-server >= 6

## Installation

```sh
bundle install
```

Copiez `.env.example` vers `.env`, et remplacez les valeurs:

- Pour l'INSEE, créer un compte sur [l'API de l'INSEE](https://api.insee.fr/),
    souscrivez à l'API Metadonnées, et c/c le consumer_key/consumer_secret

## Run

```sh
bundle exec rackup
```

Un exemple de requête valide en local:

```sh
curl "http://localhost:9292?nom_commune=Gennevilliers&annee_naissance=1960&departement_commune=92"
> {"code_insee":"75036"}
```
