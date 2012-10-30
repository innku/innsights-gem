# Innsights

This is the client gem to communicate with the Innsights API. 

Innsights is the service that gives you the power to answer:

* ¿What are your users doing?
* ¿Which ones are behaving the way you want?
* ¿How can you replicate this behaviour?

Innsights answers these questions by giving you an easy way to track the features in your application, the users getting involved with those features and the characteristics of those users.

This is the getting started guide, there is also the [Full code documentation](http://rubydoc.info/github/innku/innsights-gem/master/frames)

# Getting Started

You have an Innsights account right? 

Not yet? [Get one right here](http://innsights.me).

## 1. Get the gem

On your **Gemfile**

```ruby
gem 'innsights', :github => "innku/innsights-gem"
```

#### Living on the edge (Gem's latest bells and whistles)

```ruby
gem 'innsights', :github => "innku/innsights-gem", :branch => 'develop'
```

## 2. Set it up

### Run the generator:

```
rails generate innsights:install 
```

The generator will prompt for your `email` and `password`. Be kind and comply.

Two files will be created:

* **config/innsights.yml** (Credentials and configuration)
* **config/initializers/innsights.rb** (Action tracking configuration)

Not using Rails? See [Stand alone setup](https://github.com/innku/innsights-gem/wiki/Stand-alone-setup-and-installation)

## 3. Setup the users

To relate the actions happening on your application with your actual users, we need you to specify the class that stores your users information and the methods that hold the pieces of data that Innsights needs.

```ruby
Innsights.setup do
  ...
  user User do
    display :name                  
    id      :your_id
    group   :group_class
  end    
  ...
end    
```

The `user` DSL specifies:

* `display`: Human readable string of your user. Defaults to: `:to_s`
* `id`: Unique identifier. Defaults to: `:id`

Optionally, if your users belong to a group such as a company or a team and it has an attribute that relates the two you can specify it with:

* `group`: You'll need to specify the id and display for the group as well. More on that on the next section

If your using the defaults and your users do not belong to any group, your user setup could look like this:

```ruby
Innsights.setup do
  ...
  user User  
  ...
end    
```

## 4. Setup the groups

If you want to group your users in a group model such as a company, or a team, you will also need to specify an id and display for that group.

```ruby
Innsights.setup do
  ...
  group GroupClass do
    display  :name
    id       :your_id
  end
  ...
end
```
The `group` DSL specifies:

* `display`: Human readable string of your group. Defaults to: `:to_s`
* `id`: Unique identifier. Defaults to: `:id`

If your groups use both the specified defaults, the configuration might loook like:

```ruby
Innsights.setup do
  ...
  group GroupClass
  ...
end
```

## 5. Track your actions

There are three ways to report what your users are doing to Innsights.

### The Fast way

The only mandatory attribute is the name

```ruby
Innsights.report('Purchased Book').run
```

Optional attributes can be added. The user is strongly encouraged to be:

```ruby
Innsights.report('Purchased Book', user: current_user, :created_at: 1.day.ago).run
```

If the tracked action moves any actionable metrics, you are encouraged to track them as well

```ruby
Innsights.report('Purchased Book', user: current_user, measure: {money: @book.price}).run
```

[What are metrics?](https://github.com/innku/innsights-gem/wiki/What-are-actions-and-metrics%3F)

The attributes of an action are:

* `name`
* `created_at`
* `user`
* `measure` (hash of actionable metrics with numeric values)

This Innsights.report method can be called anywhere in your application.

Also important: a group can be explicitly set and it will supercede that of the user configuration. 

### The DSL way

A cleaner way of specifying the reports is at the initializer in: **config/initializers/innsights.rb**

#### Report on model callbacks

```ruby
Innsights.setup do
  ...
  watch Tweet do
    report      'New Tweet'
    user        :user
    created_at  :created_at
    upon        :after_create
  end
  ...
end
```

Every DSL method can receive a block that will yield the Model Record

```ruby
Innsights.setup do
  ...
  watch Tweet do
    report      'Delete Tweet'
    user        :user
    created_at  :created_at
    measure     :chars, with: lambda {|tweet| tweet.body.size }
    upon        :after_destroy
  end
  ...
end
```

The DSL has the same methods that the Innsights.report optional attributes, with the addition of:

  * `upon`: Defaults to: `:after_create`

#### Report after a controller action

This will send a report to Innsights after accessing to the `users#new` action.

```ruby
watch 'account#prices' do
  report  'Upgrade intention'
  user    :current_user
  measure :
end
```

```ruby
watch 'home#contact' do
  report 'Seeking Information'
end
```

NOTE: if you pass a block to a dsl method, it will yield the controller instance

#### Special cases

A condition can be added to a report to specify when the action will be triggered. 

```ruby
watch Tweet do
  report :tweet_with_link, if: lambda{|tweet| tweet.has_link? }
end
```

The measure attribute can be called more than once to add additional Actionable Metrics

```ruby
watch Tweet do
  report 'New Tweet'
  measure words:, with: :word_count          #calls tweet.word_count
  measure characters:, with: :char_count     #calls tweet.char_count
end
```

## 6. Queueing action reports

* **Resque:** Requires that you have [resque](https://github.com/defunkt/resque) installed and resque workers running.

```ruby
  Innsights.setup do
    ...
    config do
      queue :resque
    end
    ...
  end
```

* **Delayed_job:** Requires that you have [delayed_job](https://github.com/collectiveidea/delayed_job)  installed and delayed_job workers running.

```ruby 
Innsights.setup do
    ...
    config do
      queue :delayed_job
    end
    ...
  end
```

Also check out [other configuration Options](https://github.com/innku/innsights-gem/wiki/Configuration-Options) for details.

# License 

We have a LICENSE File. Check it out.