#!/bin/bash
set -e


# Setup /etc/hosts to allow inter-app communication outside of dev environment
if [ "$RAILS_ENV" = '' -o "$RAILS_ENV" = 'development' ]; then
  echo "Bundling gems"
  bundle install --jobs 4 --retry 3
  # setup gopro-dev.com so we can talk to other services
  echo '172.17.42.1 lobsters-dev.com' >> /etc/hosts
  echo '172.17.42.1 localhost' >> /etc/hosts
fi

# Remove pids so we can run the app
echo "Removing contents of tmp dirs"
rm -f tmp/pids/*.pid
bundle exec rake tmp:clear

if [ "$RAILS_ENV" != 'development' -a "$BUILD_ASSETS" = 'True' -a "$RAILS_ENV" != "" ]; then
  echo "Precompiling assets"
  rake assets:precompile
fi

# Symlink the log file to stdout for Docker
if [ "$RAILS_ENV" != '' -a "$RAILS_ENV" != 'development' ]; then
  echo "Symlinking to /code/log/$RAILS_ENV\.log"
  ln -sf /dev/stdout /code/log/$RAILS_ENV\.log
fi

# Seed if neccessary
if [ "$DB_SEED" = 'True' ]; then
  echo "Seeding database"
  rake db:seed
fi

# TODO some kind of rake db:create magic (but only if it hasn't been done already)
rake db:create db:migrate

# execute the actual command of the image
# for example, this is likely "foreman start"
# THIS MUST BE THE LAST LINE OF THIS FILE
# This was before foreman was run in this command
# exec "$@"
bundle exec rails s
