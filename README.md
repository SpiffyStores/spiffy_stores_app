SpiffyStores App
================
[![Build Status](https://travis-ci.com/SpiffyStores/spiffy_stores_app.svg?branch=master)](https://travis-ci.com/SpiffyStores/spiffy_stores_app)

Spiffy Stores Application Rails engine and generator

#### NOTE : Versions 8.0.0 through 8.2.3 contained a CSRF vulnerability that was addressed in version 8.2.4. Please update to version 8.2.4 if you're using an old version.

Table of Contents
-----------------
* [**Description**](#description)
* [**Quickstart**](#quickstart)
* [**Installation**](#installation)
  * [Rails Compatibility](#rails-compatibility)
* [**Generators**](#generators)
 * [Default Generator](#default-generator)
 * [Install Generator](#install-generator)
 * [Shop Model Generator](#shop-model-generator)
 * [Home Controller Generator](#home-controller-generator)
 * [App Proxy Controller Generator](#app-proxy-controller-generator)
 * [Controllers, Routes and Views](#controllers-routes-and-views)
* [**Mounting the Engine**](#mounting-the-engine)
* [**Managing Api Keys**](#managing-api-keys)
* [**WebhooksManager**](#webhooksmanager)
* [**ScripttagsManager**](#scripttagsmanager)
* [**AfterAuthenticate Job**](#afterauthenticate-job)
* [**SpiffyStoresApp::SessionRepository**](#spiffystoresappsessionrepository)
* [**AuthenticatedController**](#authenticatedcontroller)
* [**AppProxyVerification**](#appproxyverification)
 * [Recommended Usage](#recommended-usage)
* [**Troubleshooting**](#troubleshooting)
 * [Generator spiffy_stores_app:install hangs](#generator-spiffy_stores_appinstall-hangs)
* [**Testing an embedded app outside the Spiffy Stores admin**](#testing-an-embedded-app-outside-the-spiffy-stores-admin)
* [**App Tunneling**](#app-tunneling)
* [**Questions or problems?**](#questions-or-problems)


Description
-----------
This gem includes a Rails Engine and generators for writing Rails applications using the Spiffy Stores API. The Engine provides a SessionsController and all the required code for authenticating with a shop via Oauth (other authentication methods are not supported).

The [example](https://github.com/SpiffyStores/spiffy_stores_app/tree/master/example) directory contains an app that was generated with this gem. It also contains sample code demonstrating the usage of the embedded app sdk.

*Note: It's recommended to use this on a new Rails project, so that the generator won't overwrite/delete some of your files.*

Installation
------------
To get started add spiffy_stores_app to your Gemfile and bundle install

``` sh
# Create a new rails app
$ rails new my_spiffy_stores_app
$ cd my_spiffy_stores_app

# Add the gem spiffy_stores_app to your Gemfile
$ echo "gem 'spiffy_stores_app'" >> Gemfile
$ bundle install
```

Now we are ready to run any of the spiffy_stores_app generators. The following section explains the generators and what they can do.


#### Rails Compatibility

The lastest version of spiffy_stores_app is compatible with Rails `>= 5`. Use version `<= v7.2.8` if you need to work with Rails 4.


Generators
----------

### Default Generator

The default generator will run the `install`, `shop`, and `home_controller` generators. This is the recommended way to start your app.

```sh
$ rails generate spiffy_stores_app --api_key <your_api_key> --secret <your_app_secret>
```


### Install Generator

```sh
$ rails generate spiffy_stores_app:install

# or optionally with arguments:

$ rails generate spiffy_stores_app:install --api_key <your_api_key> --secret <your_app_secret>
```

Other options include:
* `application_name` - the name of your app, it can be supplied with or without double-quotes if a whitespace is present. (e.g. `--application_name Example App` or `--application_name "Example App"`)
* `scope` - the Oauth access scope required for your app, eg **read_products, write_orders**. *Multiple options* need to be delimited by a comma-space, and can be supplied with or without double-quotes
(e.g. `--scope read_products, write_orders, write_products` or `--scope "read_products, write_orders, write_products"`)
* `embedded` - the default is to generate an embedded app, if you want a legacy non-embedded app then set this to false, `--embedded false`

You can update any of these settings later on easily, the arguments are simply for convenience.

The generator adds SpiffyStoresApp and the required initializers to the host Rails application.

After running the `install` generator, you can start your app with `bundle exec rails server` and install your app by visiting localhost.


### Shop Model Generator

```sh
$ rails generate spiffy_stores_app:shop_model
```

The `install` generator doesn't create any database tables or models for you. If you are starting a new app its quite likely that you will want a shops table and model to store the tokens when your app is installed (most of our internally developed apps do!). This generator creates a shop model and a migration. This model includes the `SpiffyStoresApp::SessionStorage` concern which adds two methods to make it compatible as a `SessionRepository`. After running this generator you'll notice the `session_repository` in your `config/initializers/spiffy_stores_app.rb` will be set to the `Shop` model. This means that internally SpiffyStoresApp will try and load tokens from this model.

*Note that you will need to run rake db:migrate after this generator*


### Home Controller Generator

```sh
$ rails generate spiffy_stores_app:home_controller
```

This generator creates an example home controller and view which fetches and displays products using the SpiffyStoresAPI


### App Proxy Controller Generator

```sh
$ rails generate spiffy_stores_app:app_proxy_controller
```

This optional generator, not included with the default generator, creates the app proxy controller to handle proxy requests to the app from your shop storefront, modifies 'config/routes.rb' with a namespace route, and an example view which displays current shop information using the LiquidAPI


### Controllers, Routes and Views

The last group of generators are for your convenience if you want to start overriding code included as part of the Rails engine. For example by default the engine provides a simple SessionController, if you run the `rails generate spiffy_stores_app:controllers` generator then this code gets copied out into your app so you can start adding to it. Routes and views follow the exact same pattern.

Mounting the Engine
-------------------

Mounting the Engine will provide the basic routes to authenticating a shop with your custom application. It will provide:

| Verb   | Route                         | Action                       |
|--------|-------------------------------|------------------------------|
|GET     |'/login'                       |Login                         |
|POST    |'/login'                       |Login                         |
|GET     |'/auth/spiffy/callback'        |Authenticate Callback         |
|GET     |'/logout'                      |Logout                        |
|POST    |'/webhooks/:type'              |Webhook Callback              |


The default routes of the Spiffy Stores rails engine, which is mounted to the root, can be altered to mount on a different route. The `config/routes.rb` can be modified to put these under a nested route (say `/app-name`) as:

```ruby
mount SpiffyStoresApp::Engine, at: '/app-name'
```

This will create the Spiffy Stores engine routes under the specified Subdirectory, as a result it will redirect new consumers to `/app-name/login` and following a similar format for the other engine routes.

To use named routes with the engine so that it can route between the application and the engine's routes it should be prefixed with `main_app` or `spiffy_stores_app`.

```ruby
main_app.login_path # For a named login route on the rails app.

spiffy_stores_app.login_path # For the spiffy stores app store login route.
```

Managing Api Keys
-----------------

The `install` generator places your Api credentials directly into the spiffy_stores_app initializer which is convenient and fine for development but once your app goes into production **your api credentials should not be in source control**. When we develop apps we keep our keys in environment variables so a production spiffy_stores_app initializer would look like this:

```ruby
SpiffyStoresApp.configure do |config|
  config.application_name = 'Your app name' # Optional
  config.api_key = ENV['SPIFFY_STORES_CLIENT_API_KEY']
  config.secret = ENV['SPIFFY_STORES_CLIENT_API_SECRET']
  config.scope = 'read_customers, read_orders, write_products'
  config.embedded_app = true
end
```


WebhooksManager
---------------

SpiffyStoresApp can manage your app's webhooks for you by setting which webhooks you require in the initializer:

```ruby
SpiffyStoresApp.configure do |config|
  config.webhooks = [
    {topic: 'carts/update', address: 'https://example-app.com/webhooks/carts_update'}
  ]
end
```

When the oauth callback is completed successfully SpiffyStoresApp will queue a background job which will ensure all the specified webhooks exist for that shop. Because this runs on every oauth callback it means your app will always have the webhooks it needs even if the user uninstalls and re-installs the app.

SpiffyStoresApp also provides a WebhooksController that receives webhooks and queues a job based on the webhook url. For example if you register the webhook from above then all you need to do is create a job called `CartsUpdateJob`. The job will be queued with 2 params `shop_domain` and `webhook` which is the webhook body.

If you'd rather implement your own controller then you'll want to use the WebhookVerfication module to verify your webhooks:

```ruby
class CustomWebhooksController < ApplicationController
  include SpiffyStoresApp::WebhookVerification

  def carts_update
    SomeJob.perform_later(spiffy_stores_domain: shop_domain, webhook: params)
    head :ok
  end
end
```

The module skips the `verify_authenticity_token` before_action and adds an action to verify that the webhook came from Spiffy Stores.

The WebhooksManager uses ActiveJob, if ActiveJob is not configured then by default Rails will run the jobs inline. However it is highly recommended to configure a proper background processing queue like sidekiq or resque in production.

SpiffyStoresApp can create webhooks for you using the `add_webhook` generator. This will add the new webhook to your config and create the required job class for you.

```
rails g spiffy_stores_app:add_webhook -t carts/update -a https://example.com/webhooks/carts_update
```

where `-t` is the topic and `-a` is the address the webhook should be sent to.

ScripttagsManager
-----------------

As with webhooks, SpiffyStoresApp can manage your app's scripttags for you by setting which scripttags you require in the initializer:

```ruby
SpiffyStoresApp.configure do |config|
  config.scripttags = [
    {event:'onload', src: 'https://my-spiffy-stores-app.herokuapp.com/fancy.js'}
    {event:'onload', src: ->(domain) { dynamic_tag_url(domain) } }
  ]
end
```

Scripttags are created in the same way as the Webhooks, with a background job which will create the required scripttags.

If `src` responds to `call` its return value will be used as the scripttag's source. It will be called on scripttag creation and deletion.

SpiffyStoresApp::SessionRepository
-----------------------------

`SpiffyStoresApp::SessionRepository` allows you as a developer to define how your sessions are retrieved and stored for a shop. The `SessionRepository` is configured using the `config/initializers/spiffy_stores_session_repository.rb` file and can be set to any object that implements `self.store(spiffy_stores_session)` which stores the session and returns a unique identifier and `self.retrieve(id)` which returns a `SpiffyStoresAPI::Session` for the passed id. See either the `InMemorySessionStore` or the `SessionStorage` module for examples.

If you only run the install generator then by default you will have an in memory store but it **won't work** on multi-server environments including Heroku. If you ran all the generators including the shop_model generator then the Shop model itself will be the `SessionRepository`. If you look at the implementation of the generated shop model you'll see that this gem provides an activerecord mixin for the `SessionRepository`. You can use this mixin on any model that responds to `spiffy_stores_domain` and `spiffy_stores_token`.

AuthenticatedController
-----------------------

The engine includes a controller called `SpiffyStoresApp::AuthenticatedController` which inherits from `ApplicationController`. It adds some before_filters which ensure the user is authenticated and will redirect to the login page if not. It is best practice to have all controllers that belong to the Spiffy Stores part of your app inherit from this controller. The HomeController that is generated already inherits from AuthenticatedController.

AppProxyVerification
--------------------

The engine provides a mixin for verifying incoming HTTP requests sent via an App Proxy. Any controller that `include`s `SpiffyStoresApp::AppProxyVerification` will verify that each request has a valid `signature` query parameter that is calculated using the other query parameters and the app's shared secret.

### Recommended Usage

1. Use the `namespace` method to create app proxy routes
    ```ruby
    # config/routes.rb
    namespace :app_proxy do
      # simple routes without a specified controller will go to AppProxyController
      # GET '/app_proxy/basic' will be routed to AppProxyController#basic
      get :basic

      # this will route GET /app_proxy to AppProxyController#main
      root action: :main

      # more complex routes will go to controllers in the AppProxy namespace
      resources :reviews
      # GET /app_proxy/reviews will now be routed to
      # AppProxy::ReviewsController#index, for example
    end
    ```

2. `include` the mixin in your app proxy controllers
    ```ruby
    # app/controllers/app_proxy_controller.rb
    class AppProxyController < ApplicationController
      include SpiffyStoresApp::AppProxyVerification

      def basic
        render text: 'Signature verification passed!'
      end
    end

    # app/controllers/app_proxy/reviews_controller.rb
    class ReviewsController < ApplicationController
      include SpiffyStoresApp::AppProxyVerification
      # ...
    end
    ```
3. Contact us for further information on this feature.

Troubleshooting
---------------

### Generator spiffy_stores_app:install hangs

Rails uses spring by default to speed up development. To run the generator, spring has to be stopped:

```sh
$ bundle exec spring stop
```

Run spiffy_stores_app generator again.

Testing an embedded app outside the Spiffy Stores admin
-------------------------------------------------------

By default, loading your embedded app will redirect to the Spiffy Stores admin, with the app view loaded in an `iframe`. If you need to load your app outside of the Spiffy Stores admin (e.g., for performance testing), you can change `forceRedirect: false` to `true` in `SpiffyApp.init` block in the `embedded_app` view. To keep the redirect on in production but off in your `development` and `test` environments, you can use:

```javascript
forceRedirect: <%= Rails.env.development? || Rails.env.test? ? 'false' : 'true' %>
```

Questions or problems?
----------------------

https://www.spiffystores.com.au/kb/An_Introduction_to_the_Spiffy_Stores_API <= Read the docs!

License
-------

Copyright (c) 2018 Spiffy Stores

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
