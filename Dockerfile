FROM ruby:2.2
MAINTAINER David Blooman <david.blooman@bbc.co.uk>
LABEL https://github.com/BBC-News/cloudwatch-sender

RUN mkdir  /app
ADD . /app

WORKDIR /app

RUN gem install cloudwatch-sender-0.0.1.gem

CMD ["ruby", "runner.rb"]
