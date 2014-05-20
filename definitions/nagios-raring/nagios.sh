

# set up environ for nagios
apt-get -y install apache2 wget build-essential php5-gd libgd2-xpm libgd2-xpm-dev
apt-get -y install libapache2-mod-php5 apache2-utils daemon mailx postfix daemon


# create nagios account
/usr/sbin/useradd -m -s /bin/bash nagios
/usr/sbin/groupadd nagios
/usr/sbin/usermod -G nagios nagios

# create nagcmd user
/usr/sbin/groupadd nagcmd
/usr/sbin/usermod -a -G nagcmd nagios
/usr/sbin/usermod -a -G nagcmd www-data

# download it
cd /tmp
wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.0.4.tar.gz
wget http://nagios-plugins.org/download/nagios-plugins-2.0.tar.gz

# install nagios
tar zxvf nagios-4.0.4.tar.gz
cd nagios-4.0.4
./configure --with-nagios-group=nagios --with-command-group=nagcmd -–with-mail=/usr/sbin/sendmail --with-httpd-conf=/etc/apache2/conf-available/
make all
make install
make install-init
make install-config
make install-commandmode

cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

# install plugins
cd /tmp
tar zxvf nagios-plugins-2.0.tar.gz
cd nagios-plugins-2.0
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install

# set up web server
make install-webconf
a2enconf nagios.conf
a2enmod cgi
echo nagiosadmin | htpasswd –ic /usr/local/nagios/etc/htpasswd.users nagiosadmin

# Set up start script
ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios
service nagios start
service apache2 restart
