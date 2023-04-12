FROM ruby:3.1.2

RUN apt-get update -qq && apt-get install -y redis-server

RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN bundle install --without test development

COPY . /myapp

CMD ./docker/start.sh

EXPOSE 9292
