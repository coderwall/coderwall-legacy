# Getting started with Fig

## Prerequisites

Head to [http://www.fig.sh/install.html](http://www.fig.sh/install.html) and install Docker and Fig. You'll find instructions there for Linux, Mac and Windows.

## Git'r done

Now let's bootstrap the database and start up the app:

    $ fig up

This will take a while to download all the Docker images to run Postgres, Redis, Elasticsearch and MongoDB. Once it's all done, kill it with ctrl-c and we'll create the databases:

    $ fig run web rake db:setup

Now we're all ready!

    $ fig up

If you're running on Linux, you should be able to open up the app at http://0.0.0.0:5000

If you're running `boot2docker` then you can get the address with:

    $ boot2docker ip

Then open up http://192.168.59.103:5000