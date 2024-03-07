# Lookup du code INSEE de la commune de naissance en fonction d'infos d'identité

[![CI](https://github.com/skelz0r/identite_pivot_code_insee_naissance_lookup/actions/workflows/tests.yml/badge.svg)](https://github.com/skelz0r/identite_pivot_code_insee_naissance_lookup/actions/workflows/tests.yml)

Cette webapp permet à l'aide d'un triplet d'informations d'identité de retrouver
le code INSEE de la commune de naissance d'un utilisateur.

Le triplet est le suivant:

1. `nom commune`, `string`, nom de la commune de naissance à la date de la
   naissance ;
2. `annee de naissance`, `string`, année (format YYYY) de naissance de l'usager
3. `code departement de naissance`, `string`, code (format NN) insee du
   département de naissance à la date de la naissance.

A l'aide de ces 3 infos, l'API renvoie le code insee de la commune à l'année de
naissance de l'utilisateur.

## Contexte

Dans le cadre d'API Particulier, certaines API acceptent des informations dit
[Identité
Pivot](https://partenaires.franceconnect.gouv.fr/fcp/fournisseur-identite#identite-pivot).

Dans ces informations, il y a le code INSEE de la commune de naissance. Code que
peu d'usagers (voir aucun) ne connaisse, et qui peut varier dans le temps (pour
cause de fusion/migration/autre opération entre les communes). Ces diverses
opérations rendent la tâche de recherche de correspondance ardue.

Cette webapp est une expérimentation/un service permettant de récupérer ce code
insee à l'aide d'un triplet connue par un usager (décrit ci-dessus).

## Explications algorithme

L'algorithme fonctionne de cette manière:

1. Recherche sur l'[API metadonnées de l'INSEE](https://api.insee.fr/catalogue/site/themes/wso2/subthemes/insee/pages/item-info.jag?name=M%C3%A9tadonn%C3%A9es&version=V1&provider=insee),
   avec le couple (nom de la commune, année), si il n'y a qu'un résultat: on
   renvoie le code ;
2. Si il y a plusieurs résultats, on filtre en fonction du département, sinon
   le numéro de département est ignoré

Étant donné que la commune de naissance est généralement une commune comportant
une maternité, les possibles homonymes de communes au sein d'un même département
sont peu probables (et d'ailleurs non existant en 2023).

### Possibles limitations

Liste non exhaustive:

- Ne fonctionne qu'avec les communes en France
- Commune dont il existe un homonyme dans le même département (non existant en
  2023)

Si vous pensez qu'il existe d'autres cas, n'hésitez pas à ouvrir un ticket.

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

### with Docker

```sh
docker build . -t identite_pivot_code_insee_naissance_lookup:main
```

## Run

```sh
bundle exec rackup
```

### with Docker

```sh
docker run -p 9292:9292 identite_pivot_code_insee_naissance_lookup:main
```

## Check if OK

Un exemple de requête valide en local:

```sh
curl "http://localhost:9292?nom_commune=Gennevilliers&annee_naissance=1960&departement_commune=92"
> {"code_insee":"75036"}
```

## Tests

```sh
bundle exec rspec
```

La stack de tests utilise VCR pour enregistrer les nouvelles interactions sur
l'INSEE. Vous pouvez ajouter des tests dans le fichier
[examples.csv](./spec/examples.csv).

## Deploy

```sh
fly deploy
```

Déployé sur [fly.io](https://fly.io/)

Url: [https://identite-pivot-code-insee-naissance-lookup.fly.dev](https://identite-pivot-code-insee-naissance-lookup.fly.dev)

Un exemple de curl:

```sh
curl "https://identite-pivot-code-insee-naissance-lookup.fly.dev/?nom_commune=Gennevilliers&annee_naissance=2000&departement_commune=92"
```

## TODO

* Enhance les jeux de tests
