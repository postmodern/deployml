# DeploYML

* [deployml.rubyforge.org](http://deployml.rubyforge.org/)
* [github.com/postmodern/deployml](http://github.com/postmodern/deployml/)
* Postmodern (postmodern.mod3 at gmail.com)

## Description

DeploYML is a simple deployment solution that uses a single YAML file and
doesn not require Ruby to be installed on the server.

## Features

* Requires only **one** YAML file with a minimum of **three** things.
* Does not require anything else to be installed on the servers.
* Maintains separation between the production and development servers,
  for security reasons.
* Supports many common SCMs:
  * SubVersion (SVN)
  * Mercurial (Hg)
  * Git
  * Rsync
* Supports the Thin web-server.
* Supports any Operating System that supports Ruby and SSH.

## Examples

Specifying `source` and `dest` URIs as Strings:

    scm: git
    source: git@dev.example.com/var/git/project.git
    dest: deploy@www.example.com/var/www/site

Specifying `source` and `dest` URIs as Hashes:
      
    scm: git
    source:
      user: git
      host: dev.example.com
      path: /var/git/project.git
    dest:
      user: deploy
      host: www.example.com
      path: /var/www/site

Specifying a `server` option:

    scm: git
    source: git@dev.example.com/var/git/project.git
    dest: deploy@www.example.com/var/www/site
    server: apache

Specifying a `server` with options:

    scm: git
    source: git@dev.example.com/var/git/project.git
    dest: deploy@www.example.com/var/www/site
    server:
      name: thin
      options:
        servers: 4
	deamonize: true
	socket: /var/run/thin.sock
	rackup: true

Execute a command on the deploy server:

    $ rake deploy:invoke['whoami']
    Successfully loaded deploy.yml
    deploy

## Install

    $ sudo gem install deployml

## License

See {file:LICENSE.txt} for license information.

