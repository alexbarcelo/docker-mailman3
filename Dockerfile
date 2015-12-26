FROM python:3.4

MAINTAINER Alex Barcelo <alex.barcelo@gmail.com>

#########################################################
# Prepare the user mailman, which will run the commands #
#########################################################
# explicitly set user/group IDs
RUN groupadd -r mailman --gid=999 && useradd -r -g mailman --uid=999 mailman

# grab gosu for easy step-down from root
RUN gpg --keyserver pgp.mit.edu --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& apt-get purge -y --auto-remove ca-certificates wget

########################################
# Proceed to prepare the mailman stuff #
########################################
RUN mkdir /opt/mailman
RUN chown mailman:mailman /opt/mailman

# Install some extras required for psycopg2 (Postgres Python wrapper)
RUN apt-get update && apt-get install -y \
                postgresql-client libpq-dev \
                gcc \
        --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Python requirements
COPY requirements.txt /
RUN pip install --no-cache-dir -r /requirements.txt

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres
ENV POSTGRES_HOST postgres
ENV POSTGRES_PORT 5432

ENV MAILMAN_ADMIN_USER mailman
ENV MAILMAN_ADMIN_PASSWORD mailman

ENV HYPERKITTY_HOST hyperkitty
ENV HYPERKITTY_PORT 8000
ENV HYPERKITTY_ARCHIVER_API_KEY hyperkitty

EXPOSE 8024
EXPOSE 8001
CMD ["start"]
