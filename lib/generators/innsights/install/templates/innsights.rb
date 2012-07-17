# Extensive Docs at http://github.com/innku/innsights-gem

Innsights.setup do
  
  # User Configuration sample
  # Sample of the configuration using all defaults  
  
  # user :User do
  #   group :company 
  # end
  
  ## Report Configuration Sample
  # Specify user in every action you want a leaderboard
  # Actions can be reported upon any record callback
  
  # watch Post do
  #   report  'Publication'
  #   user    :user
  # end
  #
  # watch Comment do
  #   report  'Mind Changer'
  #   user    :commenter
  #   upon    :update
  # end
  
  ## All options can take blocks for more flexibility 
  
  # watch Favorite do
  #   report      { |object| object.favorite category}
  #   created_at  :timestamp
  # end
  
  # Registration configuration sample
  # No user is required when you dont want a leaderboard
  
  # watch User do
  #   report :registration
  # end
  
  ## Controller actions can also repost to Innsights
  
  # Params:
  #   "controller#action": Speficies the controller and actions when it should report to innsights
  #
  # Options:
  #   is_user(Detault false): Set to true if it will act directly on a user 
  #
  # on 'user#new' do
  #   report 'New User'
  #   user   :current_user
  #   is_user true
  # end


  ## Configuration can be done inside a config block

  # Params:
  #   envs: Specify the config options for specific enviroments(:development, :test, :production). 
  #         If no options env is pass, it will take effect on any enviroment
  #
  # Options: 
  #   queue (Default nil): Speficies a queue_system(:resque, :delayed_job) for reporting to Innsights
  #   test  (Default false): Used for setting the enviroment on test mode
  #
  # NOTE: if using delayed_job please check https://github.com/collectiveidea/delayed_job/wiki/Backends 
  # and install the apropiate backend dependency on your application
  
  # config :development do
  #   queue :resque
  #   test  true
  # end
  #
end
