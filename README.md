# DeploYML

* [Source](http://github.com/postmodern/deployml)
* [Issues](http://github.com/postmodern/deployml/issues)
* [Documentation](http://rubydoc.info/gems/deployml/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

DeploYML is a simple deployment solution that uses a single YAML file,
Git and SSH.

## Features

* Requires only **one YAML file** (`config/deploy.yml`) with a minimum of
  **two** settings (`source` and `dest`).
* Supports multiple deployment environments (`config/deploy/staging.yml`).
* Supports [Git](http://www.git-scm.com/).
* Can deploy Ruby web applications or static sites.
* Supports common Web Servers:
  * [Apache](http://www.apache.org/)
  * [Mongrel](https://github.com/fauna/mongrel)
  * [Thin](http://code.macournoyer.com/thin/)
* Supports common Web Application frameworks:
  * [Rails](http://rubyonrails.org/):
    * [Bundler](http://gembundler.com/)
    * ActiveRecord
    * [DataMapper](http://datamapper.org/)
* **Does not** require anything else to be installed on the servers.
* **Does not** use `net-ssh`.
* Supports any Operating System that supports Ruby and SSH.
* Provides a simple command-line interface using Thor.

## Examples

Specifying `source` and `dest` URIs as Strings:

    source: git@github.com:user/project.git
    dest: deploy@www.example.com/var/www/site

Specifying `dest` URI as a Hash:
      
    source: git@github.com:user/project.git
    dest:
      user: deploy
      host: www.example.com
      path: /var/www/site

Specifying a `server` option:

    source: git@github.com:user/project.git
    dest: deploy@www.example.com/var/www/site
    server: apache

Specifying a `server` with options:

    source: git@github.com:user/project.git
    dest: deploy@www.example.com/var/www/site
    server:
      name: thin
      options:
        servers: 4
	deamonize: true
	socket: /var/run/thin.sock
	rackup: true

Multiple environments:

    # config/deploy.yml
    source: git@github.com:user/project.git
    framework: rails3
    orm: datamapper

    # config/deploy/staging.yml
    dest: ssh://deploy@www.example.com/srv/staging
    server:
      name: thin
      options:
        config: /etc/thin/staging.yml
        socket: /tmp/thin.staging.sock

    # config/deploy/production.yml
    dest: ssh://deploy@www.example.com/srv/project
    server:
      name: thin
      options:
        config: /etc/thin/example.yml
        socket: /tmp/thin.example.sock

## Synopsis

Cold-Deploy a new project:

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

* [ruby](http://www.ruby-lang.org/) >= 1.8.6
* [addressable](http://addressable.rubyforge.org/) ~> 2.2.0
* [rprogram](http://github.com/postmodern/rprogram) ~> 0.2
* [thor](http://github.com/wycats/thor) ~> 0.14.3

## Install

    $ sudo gem install deployml

## Copyright

Copyright (c) 2010-2011 Hal Brodigan

See {file:LICENSE.txt} for license information.
