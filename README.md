# Mailman 3 container

This Docker attempts to provide a simple standalone container for
the Mailman Core. Note that I made some arbitrary design decisions 
--like using Postgres as the database, or preconfiguring the HyperKitty
archiver.

If you intend to tweak a lot the set up, then it may be a good idea 
to fork the [GitHub project](https://github.com/alexbarcelo/docker-mailman)
in order to adapt it to your needs

## Environment Variables

  - __MAILMAN_SITE_OWNER__ contains the `site_owner` property. This 
  (according to Mailman documentation) should "point to a human".
  
  - __POSTGRES_USER__ The user that will be used to connect to the
  Postgres database. Default is `postgres`
  
  - __POSTGRES_PASSWORD__ The password for the Postgres database. It 
  defaults to `postgres`, but please change it specially in deployment.
  
  - __POSTGRES_DATABASE__ The database that mailman will use. It 
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

Remember that the defaults are here for testing for convenience, but in
most deployments they should be changed, specially the __*_USER__ and 
__*_PASSWORD__ environment variables.
