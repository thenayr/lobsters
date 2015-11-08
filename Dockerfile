FROM iamnayr/ruby:latest
RUN apt-get update && apt-get install -y libsqlite3-dev libmysqlclient-dev
RUN mkdir -p /code
WORKDIR /code/
COPY Gemfile* /code/
RUN bundle install --jobs 4 --retry 3
COPY . /code/
CMD ./docker-entrypoint.sh
