FROM ubuntu:jammy
MAINTAINER suhart.hs@gmail.com

RUN apt-get update
RUN apt-get -y upgrade

# Install Apache2 / PHP 7.
RUN apt-get -y install php7.0 libapache2-mod-php7.0 php7.0-cli php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml  php7.0-mcrypt php7.0-zip php-pear php7-curl curl alien libaio1
# Copy semua Install the Oracle Instant Client
ADD oracle/oracle-instantclient-basic-21.6.0.0.0-1.el8.x86_64.rpm /tmp
ADD oracle/oracle-instantclient-devel-21.6.0.0.0-1.el8.x86_64.rpm /tmp
ADD oracle/oracle-instantclient-sqlplus-21.6.0.0.0-1.el8.x86_64.rpm /tmp
RUN alien -i /tmp/oracle-instantclient-basic-21.6.0.0.0-1.el8.x86_64.rpm
RUN alien -i /tmp/oracle-instantclient-devel-21.6.0.0.0-1.el8.x86_64.rpm
RUN alien -i /tmp/oracle/oracle-instantclient-sqlplus-21.6.0.0.0-1.el8.x86_64.rpm

# Hapus rpm
RUN rm -rf /tmp/oracle-instantclient-*.rpm

# Set up the Oracle environment variables
ENV LD_LIBRARY_PATH /usr/lib/oracle/21/client64/lib/ 
ENV ORACLE_HOME /usr/lib/oracle/21/client64/lib/

# Install the OCI8 PHP extension
RUN echo 'instantclient,/usr/lib/oracle/21/client64/lib/' | pecl install -f oci8-2.0.8
RUN echo "extension=oci8.so" > /etc/php7/apache2/conf.d/30-oci8.ini

# Enable Apache2 modules
RUN a2enmod rewrite

# Set up the Apache2 environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

# Run Apache2 in Foreground
CMD /usr/sbin/apache2 -D FOREGROUND
