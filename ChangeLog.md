### 0.5.4 / 2012-05-28

* Fixed a typo in the gemspec, which incorrectly set
  `required_rubygems_version` to the same value as `required_ruby_version`.

### 0.5.3 / 2012-05-27

* Require addressable ~> 2.2.
* Require thor ~> 0.14.

### 0.5.2 / 2011-06-21

* Added {DeploYML::Shell#ruby}.
* Override {DeploYML::LocalShell#exec} and {DeploYML::RemoteShell#exec}
  to prevent full commands from being escaped.
* Ensure that {DeploYML::Shell#ruby} and {DeploYML::Shell#rake} will
  prefix commands with `bundle exec`, if Bundler is enabled.
  * All `thin` and `mongrel_cluster` commands now support running under
    `bundle exec`.
* Merged `DeploYML::Frameworks::Rails2` and `DeploYML::Frameworks::Rails3`
  into {DeploYML::Frameworks::Rails}.

### 0.5.1 / 2011-04-25

* Emergency typo fix for {DeploYML::Environment#invoke}.

### 0.5.0 / 2011-04-22

* Added support for specifying multiple `dest` URIs.
* Added support for specifying `before` and `after` commands.
* Added {DeploYML::Configuration#each_dest}.
* Added {DeploYML::Configuration#normalize}.
* Added {DeploYML::Configuration#normalize_array}.
* Added {DeploYML::Configuration#parse_address}.
* Added {DeploYML::Configuration#parse_dest}.
* Added {DeploYML::Configuration#parse_commands}.
* Added {DeploYML::Environment#invoke_task}.
* Added {DeploYML::Environment#config}.
* Added {DeploYML::Environment#start}.
* Added {DeploYML::Environment#stop}.
* Added {DeploYML::Environment#restart}.
* Added {DeploYML::Shell#uri}.
* Added {DeploYML::Shell#exec}.
* Converted {DeploYML::Shell} into a Class.
* Raise an exception in {DeploYML::RemoteShell#ssh_uri} if the Shell URI
  does not have a host component.

### 0.4.2 / 2011-04-11

* Require rprogram ~> 0.2.
* Fixed a typo in `gemspec.yml` which crashed the Psych YAML parser.
* Fixed typos in documentation.
* Opt into [test.rubygems.org](http://test.rubygems.org/)

### 0.4.1 / 2010-12-08

* Added support for Ruby 1.8.6.
* Added {DeploYML::Configuration#bundler}.
* Auto-detect usage of [Bundler](http://gembundler.com/) by checking for a
  `Gemfile` in project directories.
* Fixed a Ruby 1.8.x specific bug where non-Strings were being passed to
  `Kernel.system`.
* Only print status messages if the mixin is enabled.

### 0.4.0 / 2010-11-29

* Require addressable ~> 2.2.0.
* Added methods to {DeploYML::Environment} inorder to mirror
  {DeploYML::Project}:
  * `invoke`
  * `setup!`
  * `update!`
  * `install!`
  * `migrate!`
  * `config!`
  * `start!`
  * `stop!`
* Added {DeploYML::Shell#status} for printing ANSI colored status messages.
* Added `DeploYML::RemoteShell#uri`.
* Added {DeploYML::RemoteShell#history}.
* Added missing documentation.
* Give the root directory passed to {DeploYML::Project#initialize} the
  default of `Dir.pwd`.
* If the destination URI has the scheme of `file:`, have
  {DeploYML::Environment#remote_shell} return a {DeploYML::LocalShell}.
  * This should facilitate local deploys.
* Perform a forced pull in {DeploYML::Environment#update}.
* Override {DeploYML::Environment#rake} in {DeploYML::Frameworks::Rails}.
* Escape all arguments of all commands in {DeploYML::RemoteShell#join}.

### 0.3.0 / 2010-11-21

* Initial release:
  * Requires only **one YAML file** (`config/deploy.yml`) with a minimum of
    **two** things (`source` and `dest`).
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

