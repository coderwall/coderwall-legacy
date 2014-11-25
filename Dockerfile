FROM whatupdave/ruby:2.1.5

RUN apt-get update -qq && apt-get install -y nodejs

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

ADD . /app
