FROM stewbawka/ruby215_nginx
MAINTAINER Stuart Wade <stewbawka@gmail.com>

RUN curl -L https://github.com/kelseyhightower/confd/releases/download/v0.7.1/confd-0.7.1-linux-amd64 -o /usr/local/bin/confd
RUN chmod +x /usr/local/bin/confd
RUN mkdir -p /etc/confd/{conf.d,templates}
ADD config/mongoid.toml /etc/confd/conf.d/mongoid.toml
ADD config/mongoid.tmpl /etc/confd/templates/mongoid.tmpl
ADD script/start /usr/local/bin/start
RUN chmod +x /usr/local/bin/start

RUN mkdir -p /campus

ADD Gemfile /campus/Gemfile
ADD Gemfile.lock /campus/Gemfile.lock

WORKDIR /campus
RUN bundle install

ADD . /campus
RUN bundle exec rake assets:precompile

ADD nginx/global.conf /etc/nginx/conf.d/
ADD nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80

CMD ["/usr/local/bin/start"]
