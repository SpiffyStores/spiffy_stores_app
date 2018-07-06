Quickstart
==========

Build and deploy a new Spiffy Stores App to Heroku in minutes

1. New Rails App (with postgres)
--------------------------------

```sh
$ rails new test-app --database=postgresql
$ cd test-app
$ git init
$ git add .
$ git commit -m 'new rails app'
```

2. Create a new Heroku app
--------------------------

The next step is to create a new heroku app. Pull up your heroku dashboard and make a new app!

cli:
```sh
$ heroku create name
$ heroku git:remote -a name
```

now we need to let git know where the remote server is so we'll be able to deploy later

web:
```sh
# https://dashboard.heroku.com/new
$ git remote add heroku git@heroku.com:appinfive.git
```

3. Contact Spiffy Stores to create app
--------------------------------------
You will be given the app credentials and the redirect_uri will be set to the required value.

* set the callback url to `https://<name>.herokuapp.com/`
* choose an embedded app
* set the redirect_uri to `https://<name>.herokuapp.com/auth/spiffy/callback`


4. Add SpiffyStoresApp to gemfile
----------------------------
```sh
$ echo "gem 'spiffy_stores_app'" >> Gemfile
$ bundle install
```

Note - its recommended to use the latest released version. Check the git tags to see the latest release and then add it to your Gemfile e.g `gem 'spiffy_stores_app', '~> 7.0.0'`

5. Run the SpiffyStoresApp generator
------------------------------------
```sh
# use the keys for your app that have been provided to you
$ rails generate spiffy_stores_app --api_key <spiffy_stores_api_key> --secret <spiffy_stores_api_secret>
$ git add .
$ git commit -m 'generated spiffy stores app'
```

If you forget to set your keys or redirect uri above, you will find them in the spiffy_stores_app initializer at: `/config/initializers/spiffy_stores_app.rb`.

We recommend adding a gem or utilizing ENV variables to handle your keys before releasing your app.

6. Deploy
---------
```sh
$ git push heroku
$ heroku run rake db:migrate
```

7. Install the App!
-------------------
`https://<name>.herokuapp.com/`
