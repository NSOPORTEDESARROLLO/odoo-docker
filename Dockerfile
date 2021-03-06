FROM 	ubuntu:bionic
MAINTAINER	cnaranjo@nsoporte.com

#Acturlizo la imagen
RUN		apt-get update; \
		apt-get -y upgrade


#Instalo dependencias para la compilacion y compilacion 
RUN		apt-get -y install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget; \
		apt-get -y install curl nodejs node-less git libpq-dev  libldap2-dev libsasl2-dev libjpeg9 libjpeg9-dev; \
		cd /tmp; \
		wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tar.xz; \
		tar -xf Python-3.7.2.tar.xz; \ 
		cd Python-3.7.2; \
		./configure --enable-optimizations; \
		make -j 1; \
		make altinstall


#Optimizaciones 
RUN		/bin/ln -s /usr/local/bin/python3.7 /usr/bin/python; \
		/bin/ln -s /usr/local/bin/pip3.7 /usr/bin/pip; \
		useradd -m -d /opt/odoo -U -r -s /bin/bash odoo; \
		cd /tmp/; \ 
		wget https://builds.wkhtmltopdf.org/0.12.1.3/wkhtmltox_0.12.1.3-1~bionic_amd64.deb; \
		apt-get -y install fontconfig fontconfig-config fonts-dejavu-core libbsd0 libexpat1 libfontconfig1 libfontenc1 libfreetype6 libjpeg-turbo8; \		
		apt-get -y install xfonts-encodings xfonts-utils libxext6 libxrender1 x11-common xfonts-75dpi xfonts-base xfonts-encodings xfonts-utils libjpeg9-dev; \
		apt-get -y install libpng16-16 libx11-6 libx11-data libxau6 libxcb1 libxdmcp6 libxext6 libxrender1 multiarch-support ucf x11-common xfonts-75dpi xfonts-base; \
		dpkg -i /tmp/wkhtmltox_0.12.1.3-1~bionic_amd64.deb



#Creando carpetas 
RUN		mkdir /custom-addons; \
		mkdir /etc/odoo; \
		mkdir /opt/data; \ 
		mkdir /opt/samples



#Instalando odoo
RUN		git clone https://www.github.com/odoo/odoo --depth 1 --branch 11.0 /opt/odoo/odoo11; \
		pip install --upgrade pip; \
		pip install wheel; \
		pip install suds-py3; \
		pip install psycopg2; \
		pip install image; \
		pip install -r /opt/odoo/odoo11/requirements.txt


#Utilidades Postgresql
RUN		cd /tmp; \
		wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/postgresql-10/10.6-0ubuntu0.18.04.1/postgresql-10_10.6.orig.tar.bz2; \
		tar -xvf postgresql-10_10.6.orig.tar.bz2; \ 
		cd postgresql-10.6; \
		./configure --prefix=/opt/postgresql; \
		make; \
		make install; \
		/bin/ln -s /opt/postgresql/bin/pg_dump /usr/bin/; \
		/bin/ln -s /opt/postgresql/bin/psql /usr/bin/



#Puertos disponibles
EXPOSE	8069/tcp


#Copiando archivos de inicio y de configuracion
COPY	files/ns-start /usr/bin/
COPY	files/odoo11.conf /opt/samples/


#Aplicando Permisos y borrando Temporales
RUN		chown -R odoo.odoo /opt/samples; \
		chown -R odoo.odoo /opt/data; \
		chown -R odoo.odoo /etc/odoo; \
		chown -R odoo.odoo /opt/odoo; \
		chown -R odoo.odoo /opt/samples; \
		chown -R odoo.odoo /custom-addons; \
		chmod +x /usr/bin/ns-start; \
		rm -rf /tmp/*


ENTRYPOINT [ "/usr/bin/ns-start" ]