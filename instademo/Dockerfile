# Use the barebones version of Ruby 2.2.3.
FROM ruby:2.2.3-slim

MAINTAINER Abdalla Ghozlan <am.ghozlan@gmail.com>

# Install dependencies:
#   - build-essential: To ensure certain gems can be compiled
#   - nodejs: Compile assets
#   - libpq-dev: Communicate with postgres through the postgres gem
#   - postgresql-client-9.4: In case you want to talk directly to postgres
RUN apt-get update && apt-get install -qq -y build-essential nodejs libpq-dev postgresql-client-9.4 --fix-missing --no-install-recommends
# Set an environment variable to store where the app is installed to inside
# of the Docker image.
ENV INSTALL_PATH /instademo
 
RUN mkdir -p $INSTALL_PATH

# This sets the context of where commands will be ran in and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH

# Ensure gems are cached and only get updated when they change. This will
# drastically increase build times when your gems do not change.
COPY Gemfile Gemfile
RUN  bundle install

# Copy in the application code from your work station at the current directory
# over to the working directory.
COPY . .

# Provide dummy data to Rails so it can pre-compile assets.
RUN bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://dummyuser:dummypass@127.0.0.1/dummydbname SECRET_TOKEN=a06e3c4225a311b58d15cae93ee9eb3c05908f05081ee0655aa8fa4e523ba11949633e488d5937ca9d951b70fd177b6b249f2b7814b33fae51097cfaa4828a56 assets:precompile

# Expose a volume so that nginx will be able to read in assets in production.
VOLUME ["$INSTALL_PATH/public"]

# The default command that gets ran will be to start the Unicorn server.
CMD bundle exec unicorn -c config/unicorn.rb

