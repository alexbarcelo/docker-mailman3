
# Mailman 3 container

This Docker attempts to provide a simple standalone container for
the Mailman Core. Note that I made some arbitrary design decisions 
--like using Postgres as the database, or preconfiguring the HyperKitty
archiver.

If you intend to tweak a lot the set up, then it may be a good idea 
to provide your own `docker-entrypoint.sh` (see the 
[GitHub project](https://github.com/alexbarcelo/docker-mailman3))
in order to adapt it to your needs.

The `docker-entrypoint.sh` generates the configuration files and 
executes the main application. If you have to make non-trivial changes
to the settings, then do it in a new `docker-entrypoint.sh`. The 
file is located at `/` (root directory) in the container, and is 
executed as the `ENTRYPOINT`.

## Setup Assumptions 

  1. The Mailman Core will run standalone.
  
  2. Postfix will be used as the MTA.
  
  3. HyperKitty will be the one and only archiver. Is not included, but
  can be reached through a normal HTTP (non-SSL) connection.

## Environment Variables

  - __MAILMAN_SITE_OWNER__ contains the `site_owner` property. This 
  (according to Mailman documentation) should "point to a human".
  
  - __POSTGRES_USER__ The user that will be used to connect to the
  Postgres database. Default is `postgres`
  
  - __POSTGRES_PASSWORD__ The password for the Postgres database. It 
  defaults to `postgres`, but please change it specially in deployment.
  
  - __POSTGRES_DB__ The database that mailman will use. It 
  defaults to `mailman`. Of course, the __POSTGRES_USER__ should have 
  been granted full permission to this database.
  
  - __POSTGRES_HOST__ The hostname or IP for the Postgres server. It
  defaults to `postgres`.
  
  - __POSTGRES_PORT__ Port for the Postgres server, by default `5432`.
  
  - __MAILMAN_ADMIN_USER__ Username for the Mailman webservice 
  (the Mailman API). Defaults to `mailman`.
  
  - __MAILMAN_ADMIN_PASSWORD__ Password for the Mailman webservice. 
  Defaults to `mailman`, but please change it specially in deployment.

  - __HYPERKITTY_HOST__ Hostname or IP for the HyperKitty installation.
  It defaults to `hyperkitty`.
  
  - __HYPERKITTY_PORT__ Port for the HyperKitty archiver API. Defaults 
  to 8000
  
  - __HYPERKITTY_ARCHIVER_API_KEY__ The HyperKitty's archiver API key.
  Defaults to `hyperkitty`.
  
  - __MAILMAN_HOST__ The host that Postfix should use in order to 
  connect to this container, for the LMTP. Note that the port used
  for LMTP is 8024. Defaults to `mailman`.
  
  - __POSTFIX_HOST__ Postfix host for mail sending. Defaults to `postfix`.
  
  - __POSTFIX_PORT__ Postfix port, defaults to `25`.

Remember that the defaults are here for testing for convenience, but in
most deployments they should be changed, specially the __*_USER__ and 
__*_PASSWORD__ environment variables.

## Postfix settings

Be sure to read the [official documentation](http://mailman.readthedocs.org/en/release-3.0/src/mailman/docs/MTA.html#postfix).

The **Transport maps** will be available at the `/opt/mailman/var/data/` 
inside the container, so it will be a good idea to set the docker to 
mount this folder to the host. Remember that those files will be updated 
when lists are changed, so copying it is not a good approach.

The connection from Postfix to Mailman is prepared to be through the 
LMTP protocol. This container uses port 8024 for LMTP and publishes 
itself in this port (in the `var/data` transport maps). On the other 
side, Mailman container expects to be able to reach a Postfix in the
port 25. This typically means that the Postfix should have the Docker
subnet as `mynetworks` and/or a properly configured `mydestination`.

You should be familiar with regular Postfix configuration when setting
this up. There are a lot of settings, and most defaults tend to work 
well with Mailman, but not always. Be ready to read some logs and 
troubleshoot things.

## Sample deployment

Prepare a file with all the environment variables that you will need. In
the following example I am not including the typical defaults, read the 
section __Environment Variables__ for more information about them.

    # File sample_deploy.env
    POSTGRES_USER=postgres
    POSTGRES_PASSWORD=postgres
    POSTGRES_DB=mailman
    
    MAILMAN_ADMIN_USER=mailman
    MAILMAN_ADMIN_PASSWORD=mailman

    HYPERKITTY_ARCHIVER_API_KEY=hyperkitty

First you need a Postgres server. Typical production deployment will 
include a persistent database and a dedicated `mailman` user. But, for
testing purposes, let's include a sample server.

    docker run --name postgres-mailman-test -d \
               --env-file sample_deploy.env \
               postgres
               
Now we have a `postgres` instance running. The mailman container can be
fired up with:

    docker run --name mailman-test -d -p 8024:8024 -p 8001:8001 \
               -v mailman_data:/opt/mailman/var/data \
               --link postgres-mailman-test:postgres \
               --env-file sample_deploy.env \
               alexbarcelo/mailman3

The `mailman3` container is ready to go. The ports it is listening on
are 8024 and 8001.
               
### Permissions in `mailman-data` directory

The `mailman` user is used inside the container, with UID and GID of 999.
This means that the `mailman-data` folder (or whatever nanme you choose)
should have write permissions for that user. This container's entrypoint
ensures that by performing a `chown -R ...` on initialization.

Additionally, postfix should have read permissions on the files 
generated in that folder --which in `mailman` defaults is 0640. It is 
up to you of the mechanism in order to achieve this. A simple approach 
is to prepare a special group in the host machine with GID=999 and add 
postfix user to that group:

    sudo addgroup --system --gid 999 docker-mailman
    sudo adduser postfix docker-mailman
    
However keep in mind that this is very specific to your deployment, and
your mileage will vary.

## About HyperKitty

The HyperKitty endpoint is not described here. Instead, a container is 
being prepared at alexbarcelo/hyperkitty.

The idea is to have a modular setting which can potentially span 
multiple nodes. The HyperKitty service requires plenty of storage for
archival purposes, and the Mailman service is expected to have high 
throughput and availability. Keep that in mind when designing your own
production deployment plan.
