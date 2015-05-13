FROM ruby:2.2

RUN bundle config --global frozen 1

RUN mkdir  /app

ADD . /app

WORKDIR /app

RUN gem install cloudwatch-sender-0.0.1.gem

CMD ["ruby", "runner.rb"]
