# syntax=docker/dockerfile:1
FROM ruby:2.7.6

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get dist-upgrade -y

ENV APP_HOME /identity-fake-server
ENV PUMA_MIN_THREADS 1
ENV PUMA_MAX_THREADS 128
ENV PUMA_NUM_WORKERS 2

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME

RUN gem install bundler:2.2.14
RUN bundle install

EXPOSE 5555
CMD ["bundle", "exec", "puma", "-p", "5555", "-C", "config/puma.rb"]
