
# Mailman 3 container

This Docker attempts to provide a simple standalone container for
the Mailman Core. Note that I made some arbitrary design decisions 
--like using Postgres as the database, or preconfiguring the HyperKitty
archiver.

If you intend to tweak a lot the set up, then it may be a good idea 
to fork the [GitHub project](https://github.com/alexbarcelo/docker-mailman)
in order to adapt it to your needs

## Setup Assumptions 

  1. The Mailman Core will run standalone.
  
  2. Postfix will be used as the MTA.
  
  3. HyperKitty will be the one and only archiver.

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

The //Transport maps// will be available at the `/var/data/` inside the
container, so it will be a good idea to set the docker to mount this 
folder to the host. Remember that those files will be updated when
lists are changed, so copying it is not a good approach.
