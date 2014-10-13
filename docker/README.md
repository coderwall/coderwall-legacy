# Docker Based Development
Docker containers are not VMs. They do not, and should not, be used in a the way your used to having with a VM. The most accurate way to think of a container is like a build on heroku. Its versioned, and ready to deploy, but not a working VM that you may ssh into. (See below for reasons)

With this in mind, the Docker based workflow is focused on having rails/sidekiq run locally, and simply connect to backing resources like postgres/redis. This means you will need to setup the local rails environment.

## Usage
 - Install [Docker](https://docs.docker.com/installation/mac/)
 - Install [Fig](http://www.fig.sh/install.html)
```
$ curl -L https://github.com/docker/fig/releases/download/0.5.2/darwin > /usr/local/bin/fig
$ chmod +x /usr/local/bin/fig
```
 - Start Containers & Set ENV
```
$ source docker.sh
```
 - Configure `.env`
 - Setup Database
```
$ bundle exec rake db:setup
```
 - Start Rails Server
```
$ bundle exec rails s
```

## Why Docker is not a VM
 - The Docker LXC part can not run on OSX native, it must run on a VM which means to do file mounting, you have to mount between the container, vm, and host. Everyone likes to put things in different places, no broad solution.
 - Restarting the rails server, requires restarting or rebuild the container context.
 - Containers do not startup or boot, they run an entrypoint script and a cmd.
 - Containers do not save data; And you do not continue from a container. Images are your starting point each run. This is why mounts are used.
 - Containers run a single command, which means its only really good at running a single process.
 - Containers should be treated as ephemeral and idempotent.
 - [If you run SSHD in your Docker containers, you're doing it wrong!](http://jpetazzo.github.io/2014/06/23/docker-ssh-considered-evil/)
 - If REALLY want to run a container as a VM; Realize you just want a VM.

From FAQ:
> ####How do containers compare to virtual machines?
> They are complementary. VMs are best used to allocate chunks of hardware resources. Containers operate at the process level, which makes them very lightweight and perfect as a unit of software delivery.
