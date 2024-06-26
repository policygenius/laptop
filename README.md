Laptop
======

Laptop is a script to set up an OS X laptop for web development.

It can be run multiple times on the same machine safely.
It installs, upgrades, or skips packages
based on what is already installed on the machine.

It is based on [thoughtbot/laptop](https://github.com/thoughtbot/laptop).

Mac Requirements
------------

* Make sure that you've installed XCode *before* running the laptop script. If you've not installed XCode, you will see the following error message:

> Can't install the software because it is not currently available from the Software Update server.

Base Install
-------

_Note: there may be times you need to enter your password_

```sh
git clone git@github.com:policygenius/laptop.git
cd laptop
sh mac.sh 2>&1 | tee ~/laptop.log
```

In order to ensure consistent Docker environment, it should be downloaded manually from the Docker website.

[Mac Download](https://www.docker.com/docker-mac)
[Windows Download](https://www.docker.com/docker-windows)

kutil Install
--------------
```sh
pushd /usr/local/bin
curl --remote-name https://raw.githubusercontent.com/policygenius/laptop/master/kutil.rb
mv kutil{.rb,}
chmod +x kutil
popd
```


Debugging
---------

Your last Laptop run will be saved to `~/laptop.log`. Read through it to see if
you can debug the issue yourself. If not, copy the lines where the script
failed into a [new GitHub
Issue](https://github.com/policygenius/laptop/issues/new) for us. Or, attach the
whole log file as an attachment.

PolicyGenius specific tips
--------------------------
* PG repo
  * If after installing all dependancies you are getting `Invalid CSS` error in the browser, it might be Node version. Check that you are using `v0.12`.

Google Cloud Platform setup
---------------------------

* Log into GCP with the `gcloud` command
  * `gcloud auth login`
* Set up GCP application default credentials
  * `gcloud auth application-default login`
* Configure `gcloud` to use the sandbox project
  * `gcloud config set project pg-sandbox-165613`
* Configure `kubectl` to use the sandbox Kubernetes cluster
  * `gcloud container clusters get-credentials sandbox-v3 --zone us-central1-f --project pg-sandbox-165613`

What it sets up
---------------

* [Bundler] for managing Ruby libraries
* [Homebrew] and [Homebrew Cask] for managing operating system libraries
* [Node.js] and [NPM], for running apps and installing JavaScript packages
* [Postgres] for storing relational data
* [Rbenv] for managing versions of Ruby
* [Redis] for storing key-value data
* [Ruby Build] for installing Rubies
* [Ruby] stable for writing general-purpose code
* [Docker] for prod-like development environments

[Bundler]: http://bundler.io/
[Homebrew]: http://brew.sh/
[Node.js]: http://nodejs.org/
[NPM]: https://www.npmjs.org/
[Postgres]: http://www.postgresql.org/
[Rbenv]: https://github.com/sstephenson/rbenv
[Redis]: http://redis.io/
[Ruby Build]: https://github.com/sstephenson/ruby-build
[Ruby]: https://www.ruby-lang.org/en/
[Docker]: https://www.docker.com/
