# Cocorico Docker & Docker Compose

This Repository provide specific Docker and Docker Compose material in order to run a [Cocorico](https://github.com/Cocolabs-SAS/cocorico) instance.


## Setup

First, clone the latest version of Cocorico

```bash
$ cd /path/to/cocorico
$ git clone https://github.com/Cocolabs-SAS/cocorico.git
```

Then start containers (databses and web) with docker-compose :

```bash
$ docker-compose up
```

You should now install composer dependencies :

```bash
$ docker exec -i -t cocorico-web composer install
```

Follow instructions given in https://github.com/Cocolabs-SAS/cocorico#application-install--configuration

You should put in your ```app/config/parameters.yml```the following settings for your databases :

```yaml
# app/config/parameters.yml
parameters:
    database_host: 'cocorico-db-mysql'
    database_port: 3306
    database_name: cocorico
    database_user: root
    database_password: cocorico #or change it in docker-compose.yml
    mongodb_server: 'mongodb://cocorico-db-mongo:27017'
    mongodb_database_name: cocorico_dev
```

Then you should setup Cocorico as described in https://github.com/Cocolabs-SAS/cocorico#installation

```bash
$ docker exec -i -t cocorico-web  chmod 744 bin/init-db
$ docker exec -i -t cocorico-web  ./bin/init-db php --env=dev
$ docker exec -i -t cocorico-web  chmod 744 bin/init-mongodb
$ docker exec -i -t cocorico-web  ./bin/init-mongodb php --env=dev
$ docker exec -i -t cocorico-web  php app/console assets:install --symlink web --env=dev
$ docker exec -i -t cocorico-web  php app/console assetic:dump --env=dev
```

**Your setup is now complete!** If you want to customize things, feel free to have a look at the Dockerfile and docker-compose.yml file

## Optional config

There is an optional ``docker-copose.yml`` available in the branch ``docker-rsync`` in this repository.
