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
* Provides convenient Rake and Thor tasks for your project.
* Provides a simple command-line util using Thor.
* Can deploy Ruby web applications or static sites.
* Supports many common SCMs:
  * SubVersion (SVN)
  * Mercurial (Hg)
  * Git
  * Rsync
* Supports a few common Web Servers:
  * Apache
  * Mongrel
  * Thin
* Supports a few Web Application frameworks:
  * Rails2 (ActiveRecord)
  * Rails3 (Bundler / ActiveRecord / DataMapper)
* Supports any Operating System that supports Ruby and SSH.

## Rake Tasks

* deploy:config
* deploy:install
* deploy:deploy
* deploy:exec[command]
* deploy:migrate
* deploy:push
* deploy:redeploy
* deploy:restart
* deploy:ssh
* deploy:start
* deploy:stop
* deploy:pull
* deploy:push
* deploy:task[name]

## Thor Tasks

* deploy:config
* deploy:deploy
* deploy:exec
* deploy:install
* deploy:migrate
* deploy:pull
* deploy:push
* deploy:rake
* deploy:redeploy
* deploy:restart
* deploy:ssh
* deploy:start
* deploy:stop

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

## Synopsis

Deploy a new project:

    $ deployml deploy

Redeploy a project:

    $ deployml redeploy

Run a rake task on the deploy server:

    $ deployml rake 'db:automigrate'

Execute a command on the deploy server:

    $ deployml exec 'whoami'

SSH into the deploy server:

    $ deployml ssh

List available tasks:

    $ deployml help

## Requirements

* [rprogram](http://github.com/postmodern/rprogram) ~> 0.1.8
* [pullr](http://github.com/postmodern/pullr) ~> 0.1.1
* [thor](http://github.com/wycats/thor) ~> 0.13.3

## Install

    $ sudo gem install deployml

## License

See {file:LICENSE.txt} for license information.

