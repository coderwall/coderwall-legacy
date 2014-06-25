<a href="http://www.coderwall.com/">![Logo](app/assets/images/logo.png)</a>

[![Build Status](https://travis-ci.org/assemblymade/coderwall.svg?branch=master)](https://travis-ci.org/assemblymade/coderwall)

[![Code Climate](https://codeclimate.com/repos/5372500ce30ba06dcb029a39/badges/aee85ae9136d5b8b525c/gpa.png)](https://codeclimate.com/repos/5372500ce30ba06dcb029a39/feed)

A community for developers to unlock & share new skills.

## Getting Started

Please see our CONTRIBUTING.md for instructions on how to get started working on Coderwall.

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

There are a couple of steps you need to take before contributing:

1. Go to https://assemblymade.com and sign up.
2. Link your GitHub account to your Assembly account in your profile settings.
3. [Fork the code](https://github.com/assemblymade/coderwall).
4. Get vagrant running
5. Run the test suite
6. If you have any issues, jump into chat, introduce yourself and ask or leave a message if no one is around.
7. Find an [interesting bounty](https://assemblymade.com/coderwall/wips) on Assembly or suggest a new one.
8. Fork and then issue a PR when you are done referencing the Bounty. (Note: Only PRs from those with valid Assembly account will be merged).

## Getting Started with Vagrant

If you're running Windows, [here's a guide written by one of our members on how to get set up.](https://github.com/assemblymade/coderwall/docs/getting_started_on_windows.md)

[Vagrant](http://vagrantup.com) is the recommended way to run Helpful on your own machine. You need to download and install [Vagrant](http://vagrantup.com/downloads) before you can continue (this will take a while to run so you may want to grab some coffee).

    git clone https://github.com/assemblymade/coderwall.git coderwall
    cd coderwall
    vagrant up

Once it's finished open up [http://localhost:5000](http://localhost:5000) in your web browser to check out Helpful.

### Gems Installation and Database Migration

Remember that you are using Vagrant, so if you run ```bundle install``` or ```rake db:migrate``` directly in your terminal it will not affect the virtual machine where CoderWall is running.

In order to run these commands, in the virtual machine, all you have to do is to run ```vagrant provision```.


### Environment Variables

If you need to change any environment variable you have to edit ```.env``` file properly and restart Rails server running:

    vagrant ssh -c "sudo restart coderwall"

## Advanced Email Configuration

### Sending with Gmail

In your .env file, change the below values for your own email and
password:

    USE_GMAIL=true
    SENDER_EMAIL_ADDRESS="email@example.com"
    SENDER_EMAIL_PASSWORD="PassWord"

Save and restart the app (`sudo restart coderwall` on vagrant)


### Receiving with Mailgun (optional)

Setting up [Mailgun](http://mailgun.com) in development takes a little work but allows you to use the
actual email workflow used in production.

1. Register for a free account at https://mailgun.com.
2. Get your Mailgun API key from https://mailgun.com/cp it starts with "key-"
and add it to your .env file as MAILGUN_API_KEY.
4. Get your Mailgun test subdomain from the same page and add it to your .env
file as INCOMING_EMAIL_DOMAIN.
5. In order to recieve webhooks from Mailgun we need to expose our development
instance to the outside world. We can use a tool called
[Ngrok](http://ngrok.com) for this. Download and setup Ngrok by following the
instructions on the [Ngrok](http://ngrok.com) site.
6. Run rake mailgun to make sure everything is setup right. It should prompt you
to create a route using `rake mailgun:create_route`.
7. Run `rake mailgun:create_route` and when prompted enter your Ngrok address
as the domain name.
8. Send a test email to helpful@INCOMING_EMAIL_DOMAIN and you should see it
appear in the helpful account.

## Copyright / License

Copyright © 2014, Assembly Made, Inc
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted and provided that the following conditions are met:

* Any redistribution or use is for noncommercial purposes only and is not redistributed or used in connection with any application that is substantially similar to it (Coderwall).
* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OF BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
