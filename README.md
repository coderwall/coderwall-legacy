<a href="http://www.coderwall.com/">![Logo](app/assets/images/logo.png)</a>

[![Code Climate](https://codeclimate.com/repos/53713d15e30ba01ff50013f0/badges/78d29b02a9f5dab80043/gpa.png)](https://codeclimate.com/repos/53713d15e30ba01ff50013f0/feed)

A community for developers to unlock & share new skills.

## Getting Started

TODO: Describe Stripe configuration
TODO: Describe GitHub configuration https://github.com/settings/applications/new

### How to work on Coderwall using Vagrant on VirtualBox

Sure you could download and install all the dependencies, services, and whatnot
on to your local workstation but ain't nobody got time for that mess.

To save time and headaches we use Vagrant. Vagrant is a automation tool for
VirtualBox that will help you spin up a virtual environment with pretty much
everything in place and ready for you to start hacking (even on Windows!)

Here's everything you need to get started working on Coderwall with Vagrant TODAY!

*At the time of writing this document we were using VirtualBox 4.3.10 and Vagrant 1.6.2.*

#### Vagrant! I already know what to do.

__If you're an experienced Vagrant user then you can fetch the base box and register it yourself.__

There's only a VirtualBox basebox right now.

        vagrant box add coderwall http://cdn.coderwall.com/vagrant/coderwall.box

#### Vagrant? VirtualBox? Let's take this one step at a time.

1. **Install VirtualBox**

    Grab the VirtualBox installer from **[here](https://www.virtualbox.org/wiki/Downloads)**.

    _At the time of writing this documentation the current version is VirtualBox 4.3.10._

    You don't have to install the VirtualBox 4.3.10 Oracle VM VirtualBox Extension Pack
    but I recommend installing it for the extra drivers.

2. **Install Vagrant**

    Grab the Vagrant installer from **[here](http://www.vagrantup.com/downloads.html)**.

    _At the time of writing this documentation the current version is Vagrant 1.6.2._

    Follow the installation instructions for your platform on the Vagrant download page.

    After installing Vagrant we need to add a couple plugins.

    If you're on a OS X/Linux system you can install the plugins by running:

        vagrant plugin install vagrant-vbguest

    The vagrant-vbguest plugin will each help with keeping the VirtualBox Guest Additions up-to-date.

3. **Git assemblymade/coderwall**

    mkdir -p ~/assemblymade
    cd ~/assemblymade
    git clone git@github.com:assemblymade/coderwall.git

    I am going to assume that the project is cloned into your home directory in
    and into a directory structure like `~/assemblymade/coderwall`.

4. **Fire it up! Fire it up! Fire it up!**

    Now that you've got VirtualBox and Vagrant installed with the source code
    cloned in `~/assemblymade/coderwall` we can start up the Vagrant instance.

        cd ~/assemblymade/coderwall
        vagrant up

    You will likely be prompted for your `sudo` password to allow VirtualBox
    to mount the shared folder using NFS.

    Since this is probably the first time you're running this command it's going
    to take a VERY long time (bandwidth willing) to run. This is because Vagrant
    needs to fetch the Coderwall base box from the Internet and it's about 1GB.
    Fortunately that really only has to be done once (unless the base box get's
    updated but that's another story).

    Once Vagrant reports that you're booted up and ready to go then you'll be
    able to SSH into the local vm similiar to any other remote box.

        # still in ~/assemblymade/coderwall
        vagrant ssh
        # whoa!
        pwd
        hostname
        ls -al
        # We're not in localhost any longer... well, you get what I mean

    Now that you're SSH'ed into the Vagrant VM it's time to run the app.

        # we're still SSH'ed into Vbox
        cd ~/assemblymade
        rvm current # should be ruby-2.1.0@coderwall
        bundle check # should be a response that everything's good
        bundle exec rails server

    If all went well the Rails server should start up on PORT 3000.

    Now go open your favorite web browser on you host machine and
    navigate to `http://localhost:3000`.

    If all goes well (and if it doesn't then check if another app is
    running on port 3000 and if there's any logging output being displayed
    in the window you were running Vagrant in) then you're going to be
    looking at the Coderwall homepage.

    Congratulations! NOW GET TO WORK! Enough dilly-dallying with your devenv.

5. **Hackety Hack!**

    Vagrant is powerful not just because it can abstract away the mess of
    managing a crazy, complicated development environment while ensuring everyone
    has a common platform to work on. It's also powerful because it will still
    let you have whatever crazy, complicated editors and tools to work on your
    code while abstracting away the nasty details of installing and configuring Postgres.

    If you're on your host computer and navigate to `~/assemblymade/coderwall` (we're all there, right?)
    and make changes to your code while Vagrant is running you'll be able to see the changes
    reflected in Vagrant immediately. Try this.

        cd ~/assemblymade/coderwall
        echo Hello, `whoami` from `hostname` >> HELLO.txt
        vagrant ssh
        cd ~/assemblymade
        cat HELLO.txt #whoa.
        echo Hello, `whoami` from `hostname` >> HELLO.txt
        exit
        cat HELLO.txt # wah-wah-wee-wa!
        rm -f HELLO.txt # yeah, it's deleted in the other spot too.

    Yeah, that's pretty awesome. Remember that NFS thing we glossed over earlier? That's
    the mechanism that Vagrant set up with VirtualBox to transparently synchronize your
    local folder with the folder on the VM. Now you can edit and manage your files from
    the comfort of your favorite OS without having to worry about copying them to the VM.

6. **All done.**

    When you're ready to call it a day and want to turn the VM off you have two options.

    You can either "turn the VM off" using `vagrant halt` or you can suspend the VM using `vagrant suspend`.

    Either way when you're ready to resume working just `vagrant up` and you're good to go.

7. **Thanks**

    I hope you enjoy working with Vagrant as much as we do and feel free to ask questions
    if you get stuck or have a problem. You're probably not alone and even if you're the
    first to encounter a rough patch you won't be the last.

## Built With

Coderwall is built from the following open source components:

- [Backbone.js](https://github.com/jashkenas/backbone)
- [ElasticSearch](http://www.elasticsearch.org/)
- [Ember.js](https://github.com/emberjs/ember.js)
- [jQuery](http://jquery.com/)
- [MongoDB](http://www.postgresql.org/)
- [PostgreSQL](http://www.postgresql.org/)
- [Redis](http://redis.io/)
- [Ruby on Rails](https://github.com/rails/rails)

Plus *lots* of Ruby Gems, a complete list of which is at [/master/Gemfile](https://github.com/assemblymade/coderwall/blob/master/Gemfile).

We use [Vagrant](http://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) to isolate and simplify the local development process.

## Contributing

TODO

## Copyright / License

Copyright © 2013, Assembly Made, Inc
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted and provided that the following conditions are met:

* Any redistribution or use is for noncommercial purposes only and is not redistributed or used in connection with any application that is substantially similar to the Selected App Idea.
* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OF BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
