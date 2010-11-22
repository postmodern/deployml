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

