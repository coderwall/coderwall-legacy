# Contributing

There are a couple of steps you need to take before contributing:

1. Go to [https://assemblymade.com](https://assemblymade.com) and sign up.
2. Link your GitHub account to your Assembly account in your profile settings.
3. Create a new WIP at [https://assemblymade.com/coderwall/wips](https://assemblymade.com/coderwall/wips).

Then just go ahead, fork the repo & issue a pull request. You're on your way to having a stake in Helpful.

## External Dependencies

### Stripe configuration

You'll need to set up a test account with Stripe for local development until this dependency is refactored out of development/test.

## GitHub configuration

You will need a GitHub application configured for local development until this dependency is refactored out of development/test.

https://github.com/settings/applications/new

## How to run Coderwall locally.

We use Vagrant to isolate all of our dependencies without polluting your normal working environment.

You're free to not use Vagrant but by the time you're done setting up you'll probably already have given up and installed Vagrant.

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
