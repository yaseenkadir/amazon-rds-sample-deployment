# Amazon RDS Sample Project
Sample that provides instructions for getting setup with Amazon RDS on AWS.

The CloudFormation templates in this project have been modified only in very small ways. By and
large, they are copy pasted from https://github.com/aws-samples/startup-kit-templates.

Please visit that page because this page is likely very out of date.

An application and an application stack deployment is also included in this project. That was
included to test the RDS deployment. This project is solely focused on RDS deployment.

## Overview
[Etched Journal](https://github.com/yaseenkadir/etchedjournal) uses a relational database to persist
entities. This project was created to explore how to deploy the database in the context of Etched.
Because of that, some opinionated choices have been made, they are:

1. The application WILL NOT use the DatabaseUser and DatabasePassword credentials to connect to RDS.
Applications will use separate accounts.
2. Database will be initialized manually (on first deploy)
3. VPC and Database resources will be deployed in separate stacks (TODO: Why?)

## Deploy
### Prerequisites
Before we deploy RDS resources we need to set up:

1. An S3 bucket which stores the CloudFormation templates
2. An EC2 keypair which is used to SSH into the bastion host

### Deployment
A bash script has been created to deploy the application

```bash
# aws-profile is optional
./deploy/deploy-infra.sh template-bucket keypair-name database-password aws-profile
```

## Postgres Database/User setup
```postgresql
/* Create the database */
CREATE DATABASE tododb;

/* Enable extension because simple app uses UUIDs */
CREATE EXTENSION pgcrypto;

/*
Create a user for the web application

The application property `spring.datasource.username` should match this username
*/
CREATE USER todoapp WITH password 'dolphins';

/* Give the user permissions to the database */
GRANT ALL ON DATABASE tododb TO todoapp;
```

### Testing PostgreSQL locally with Docker

```bash
# Run a postgres container
docker run -d --name todoapp-postgres -p 5432:5432 postgres

# Attach terminal to container
docker exec -it todoapp-postgres /bin/bash

# Connect to server as user postgres
psql -U postgres

# You can now run the commands to setup the database and the users

# Extra
# Because our app uses UUIDs we need to enable an extension to allow postgres to generate UUIDs
psql -U postgres --dbname tododb

# tododb=> CREATE EXTENSION pgcrypto;
# tododb=> SELECT gen_random_uuid(); -- tests that it can generate random uuids

# After running the commands you should be able to connect to the database using the following command
psql -h 127.0.0.1 -p 5432 -U todoapp --dbname tododb
```
