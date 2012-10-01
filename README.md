# What is Innsights?

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

# Installation

#### Stand alone installation

```
 gem install 'innsights' 
```

#### Bundler installation

Add it to the **Gemfile**

```
 gem 'innsights'
```

#### Using the latest version
NOTE: This version may not be fully stable. It is recommended to use the sable one. 

```
gem 'innsights', :git => "git://github.com/innku/innsights-gem", :branch => 'develop'

```

# Getting started
## Innsights account.
This tutorials assumes that you already have an Innsights account already set up, if this isn't the case please proceed to [create](http://innsights.me) one.

## Rails setup
Run the generator:

```
rails generate innsights:install 

```

This will ask you to enter your Innsights `email` and `password`.

Two files will be created:

**config/innsights.yml** This file contains your credentials and application information.

```
credentials:
  app: application-subdomain
  token: application-token    
```


**config/initializers/innsights.rb** This file contains the actions that will be reported to Innsights


```
Innsights.setup do
	.
	.
	.
	# Available options are listed below
end
```


## Stand alone setup

Innsights be added to any Ruby app.


**Set up your credentials**

```
require 'insights'

Innsights.setup do
  credentials 'app' => application-subdomain, 
              'token' => application-token              
end

```
** Specify the environment **
Innsights.setup do
  environment 'development'
end

## Reporting Actions to Innsights

NOTE: All of the code in this section should be added within an `Innsights.setup` block.

### Setup the users

Describe the user object structure that will be used.

``` 
  user UserClass do
  end    
```
**Default behaviour:**

* `#to_s` method is used to find the **display**.
* `#id` method is used to get the user **id**.

**Customisation: **

```
  user User do
    display :name                  
    id      :your_id
    group   :group_class
  end        
```

### Setup the groups

Describe the group object structure that will be used.

```
    group GroupClass do
    end
```

**Default behaviour:**

* `#to_s` method is used to find the **display**.
* `#id` method is used to get the user **id**.

**Customisation: **

```
    group GroupClass do
      display  :name
      id       :your_id
    end
```

Different groups can be defined.

```
    group School do
    end 
    
    group Company do
      display  :name
      id       :your_id
    end
```


### Setup the report

The reports is what will be sent to Innsights when a given action is triggered

#### Report from a model

NOTE: Model report works with any `ActiveRecord::Base` class.

This will send a report to Innsights when ever a Tweet is created.

```
  watch Tweet do
  end
```

**Default behaviour:**

* `report` Uses the object class name as the report name.
* `#user` method is called to get the user
* `#group` method is used to get the group
* Action will be triggered upon object creation.

**Customisation: **

```
  watch Tweet do
    report 'Tweet deleted'
    user   :user
    group  :company
    upon   :delete
    timestamp :time_method
  end  
```
**Add Metrics**

#### PENDING

**Conditional Reports**

A condition can be added to specify when the action will be triggered. 

```
  watch Tweet do
    report 'Tweet with link', if: lambda{|tweet| tweet.has_link? }
  end
```  
This action will only be reported to Innsights when the tweet has a link.




### Report from a controller action

This will send a report to Innsights after accessing to the `users#new` action.

```
  on 'users#new' do
    report 'New user'
  end
```

**Default behaviour:**

* **user:**       No user will be sent. 
* **group:**     No group will be sent.
* **created_at:** `Time.now` will be used for the timestamp.
* **measure:**   No metric will be sent.


**Customisation:**


```
  on 'users#new' do
    report 'New user'
    user   :current_user
    group  :company
    upon   :delete
    timestamp :time_method
  end
```
**Add Metrics**

#### PENDING

**Conditional Reports**

A condition can be added to specify when the action will be triggered. 

```
  on 'users#new' do
    report 'New user', if: lambda {|r| r.your_condition? }
  end
```

This action will only be reported to Innsights when the condition is true.




### Manually report to Innsights

Sometimes your report will no be directly related to  a model or a controller.


```
report = Innsights.report('Action Name')    #creates a report but will not send it to Innsights
report.run                                  #Sends the report to Innsights.
```
**Default behaviour:**

* **user:**       No user will be sent. 
* **group:**     No group will be sent.
* **created_at:** `Time.now` will be used for the timestamp.
* **measure:**   No metric will be sent.


**Customisation:**

```
Innsights.report('Action Name', user: @user, 
   								group: @group,  
   								created_at: 1.month.ago,    
   								measure: {words: @tweet.word_counts,   
   								          mentions: @tweet.mention_count})

```

NOTE: It uses the previously specified `display` and `id` methods to get the user and group information. 


**Add Metrics**

#### PENDING
## Options and configuration

```

config do
end
```

Specify configuration options for certain environments. 

```
config :test, :development do     
end

```

#### Queue system

**Default behaviour:**

No queue system will be used to send the actions

**Customisation:**

* **Resque:** This require you to have [resque](https://github.com/defunkt/resque) dependencies installed and resque workers running.

```
config do
  queue :resque
end
```

* **Delayed_job:** This require you to have [delayed_job](https://github.com/collectiveidea/delayed_job) dependencies installed and delayed_job workers running.

```	
config do
  queue :delay_job
end

```

#### Enable and disable reports 

Reporting actions to Innsights can be either enabled or disabled. Report to insights is enabled by default.

**Customisation**

```
config do
  enable false
end
```

#### Enter to test mode

Changes the Innsights url to a [pow](http://pow.cx/) url ('innsights.dev/')

```
config :development do
  mode :test
end
```

#### Set up your credentials

```
credentials 'app' => application-subdomain, 
            'token' => application-token              

```
#### Specify the environment

Enviroment defaults to the current Rails or Rack environment.

**Customisation**

```
  environment 'development'
  
```


## Troubleshooting 

#### PENDING

```
Rails.configuration.to_prepare do
  Innsights.setup do
  end
end
```

## Contribute

#### PENDING

## License 

#### PENDING


