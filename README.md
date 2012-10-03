# What is Innsights?

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

See [wiki](https://github.com/innku/innsights-gem/wiki) for full documentation. 

# Getting Started

This tutorial assumes that you already have an Innsights account, if this isn't the case please proceed to [create](http://innsights.me) one.

## 1. Install it

Add it to the **Gemfile**

```ruby
gem 'innsights'
```

run:

```
bundle install
```

#### Using the latest version
NOTE: This version may not be stable. It is recommended to use the sable one. 

```ruby
gem 'innsights', :git => "git://github.com/innku/innsights-gem", :branch => 'develop'

```

See [Stand alone installation](https://github.com/innku/innsights-gem/wiki/Stand-alone-setup-and-installation) for details.

## 2. Set it up

### Run the generator:

```
rails generate innsights:install 

```

Enter your Innsights `email` and `password`.

Two files will be created:

**config/innsights.yml**  It contains your credentials and application information.

```ruby
credentials:
  app: application-subdomain
  token: application-token    
```


**config/initializers/innsights.rb** It contains the actions that will be reported to Innsights


```ruby
Innsights.setup do
  .
  .
  .
  # Available options are listed below
end
```

See [Stand alone setup](https://github.com/innku/innsights-gem/wiki/Stand-alone-setup-and-installation) for details.
## 3. Setup the users

NOTE: Code in this section should be added within an `Innsights.setup` block.

Describe the user object structure that will be used.

```ruby
user UserClass  
```

**Default behavior:**

* `#to_s` method is used to get the user **display**.
* `#id` method is used to get the user **id**.

**Customization:**

```ruby
user User do
  display :name                  
  id      :your_id
  group   :group_class
end        
```

## 4. Setup the groups

NOTE: Code in this section should be added within an `Innsights.setup` block.

Describe the group object structure that will be used.

```ruby
group GroupClass
```

**Default behavior:**

* `#to_s` method is used to get the group **display**.
* `#id` method is used to get the group **id**.

**Customization:**

```ruby
group GroupClass do
  display  :name
  id       :your_id
end
```
See [Multiple groups](https://github.com/innku/innsights-gem/wiki/Multiple-Groups) for details.

## 5. Setup the reports

* Report: Lorem ipsum, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
* Action: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
* Metric: Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

See [What are actions and metrics?](https://github.com/innku/innsights-gem/wiki/What-are-actions-and-metrics%3F) for details.

### Report from a model

This will send a report to Innsights whenever a Tweet is created.

```ruby
watch Tweet do
end
```

**Default behavior:**

* `report` it uses the object class name as the report name.
* `#user` method is called to get the user
* `#group` method is used to get the group
* The action will be triggered upon object creation.

**Customization:**

```ruby
watch Tweet do
  report :tweet_deleted
  user   :user
  group  :company
  upon   :delete
  timestamp :time_method
end  
```

### Report from a controller action

This will send a report to Innsights after accessing to the `users#new` action.

```ruby
on 'users#new' do
  report :new_user
end
```

**Default behavior:**

* **user:**       No user will be sent. 
* **group:**     No group will be sent.
* **created_at:** `Time.now` will be used for the timestamp.
* **measure:**   No metric will be sent.

**Customization:**

```ruby
on 'users#new' do
  report :new_user
  user   :current_user
  group  :company
  upon   :delete
  timestamp :time_method
end
```

### Conditional Reports
NOTE: Code in this section should be added within an `Innsights.setup` block.

A condition can be added to a report to specify when the action will be triggered. 

This action will only be reported to Innsights when the tweet has a link.

```ruby
watch Tweet do
  report :tweet_with_link, if: lambda{|tweet| tweet.has_link? }
end
```

### Add metrics to your reports

Metrics are used to add measurements related to the report

Metrics can be added to any report by using the `measure` attribute. 

```ruby
watch Tweet do
  report :new_tweet
  measure words:, with: :word_count          #calls tweet.word_count
  measure characters:, with: :char_count     #calls tweet.char_count
end
```
To get the total `words` and `characters` the specified methods will be called on the tweet object.

See [Stand alone reports](https://github.com/innku/innsights-gem/wiki/Stand-alone-reports) for details.

## 6. Set configuration options

NOTE: Code in this section should be added within an `Innsights.setup` block.

Configuration options are set under the `config` block

```ruby
config do
 .
 .
 .
end
```

### Queue system

**Default behavior:**

No queue system will be used to send the actions

**Customization:**

* **Resque:** This require you to have [resque](https://github.com/defunkt/resque) dependencies installed and resque workers running.

```ruby
config do
  queue :resque
end
```

* **Delayed_job:** This require you to have [delayed_job](https://github.com/collectiveidea/delayed_job) dependencies installed and delayed_job workers running.

```ruby	
config do
  queue :delay_job
end
```

See [Configuration Options](https://github.com/innku/innsights-gem/wiki/Configuration-Options) for details.

# License 

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
