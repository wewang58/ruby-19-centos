# centos-ruby
#
# This image provide a base for running Ruby based applications. It provides
# just base Ruby installation using SCL and Ruby application server.
#
# If you want to use Bundler with C-extensioned gems or MySQL/PostGresql, you
# can use 'centos-ruby-extended' image instead.
#

FROM       centos
MAINTAINER Michal Fojtik <mfojtik@redhat.com>

# Pull in important updates and then install ruby193
#
RUN yum install --assumeyes centos-release-SCL && ( \
     echo "update"; \
     echo "install gettext tar which ruby193-ruby ruby193-ruby-devel"; \
     echo "install ruby193-rubygem-bundler ruby193-rubygem-rake"; \
     echo "install gcc-c++ automake autoconf curl-devel openssl-devel"; \
     echo "install zlib-devel libxslt-devel libxml2-devel"; \
     echo "install mysql-libs mysql-devel postgresql-devel sqlite-devel"; \
     echo "install nodejs010-nodejs"; \
     echo "run" ) | yum shell --assumeyes && yum clean all --assumeyes


# Add configuration files, bashrc and other tweaks
#
ADD ./ruby /opt/ruby/

ENV STI_SCRIPTS_URL https://raw.githubusercontent.com/openshift/ruby-19-centos/master/.sti/bin

# Create 'ruby' account we will use to run Ruby application
# Add support for '#!/usr/bin/ruby' shebang.
#
RUN mkdir -p /opt/ruby/{gems,run,src} && \
      groupadd -r ruby -f -g 433 && \
      useradd -u 431 -r -g ruby -d /opt/ruby -s /sbin/nologin -c "Ruby User" ruby && \
      chown -R ruby:ruby /opt/ruby && \
      mv -f /opt/ruby/bin/ruby /usr/bin/ruby

# Set the 'root' directory where this build will search for Gemfile and
# config.ru.
#
# This can be overridden inside another Dockerfile that uses this image as a base
# image or in STI via the '-e "APP_ROOT=subdir"' option.
#
# Use this in case when your application is contained in a subfolder of your
# GIT repository. The default value is the root folder.
#
ENV APP_ROOT .
ENV HOME     /opt/ruby
ENV PATH     $HOME/bin:$PATH

WORKDIR     /opt/ruby/src
USER ruby

EXPOSE 9292

# Display STI usage when invoked outside STI builder
#
CMD ["/opt/ruby/bin/usage"]
