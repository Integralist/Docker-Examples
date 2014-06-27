FROM ubuntu:14.04
MAINTAINER Mark McDonnell <mark.mcdx@gmail.com>

RUN apt-get -qq update
RUN apt-get -qqy install ruby ruby-dev
RUN gem install sinatra

ADD . /src

RUN cd /src

EXPOSE 4567

ENTRYPOINT ["ruby", "/src/app.rb"]
