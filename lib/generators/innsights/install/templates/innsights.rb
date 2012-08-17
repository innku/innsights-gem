# Extensive Docs at http://github.com/innku/innsights-gem

Innsights.setup do
  
  # User Configuration sample
  # Sample of the configuration using all defaults  
  
  # user :User do
  #   group :company
  # end
  # 
  # group :Company do
  #  dispaly :name
  #  id      :rfc
  # end
  #
  #
  # Innsight.report("asda", user: user, group: user.company)
  
  ## Report Configuration Sample
  # Specify user in every action you want a leaderboard
  # Actions can be reported upon any record callback
  
  # watch Post do
  #   report  'Publication'
  #   user    :user    # post.user.school
  #   group   :school  # post.school
  # end
  # 
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
  #
  # Metrics can also be reported
  #
  # watch Car do
  #   report 'Buy Car'
  #   metrics do
  #     kg    :weight
  #     money :price
  #   end
  # end
  
  ## Controller actions can also repost to Innsights
  
  # Params:
  #   "controller#action": Speficies the controller and actions when it should report to innsights
  #
  # on 'user#new' do
  #   report 'New User'
  #   user   :current_user
  # end


  ## Configuration can be done inside a config block

  # Params:
  #   envs: Specify the config options for specific environments(:development, :test, :production). 
  #         If no options env is pass, it will take effect on any environment
  #
  # Options: 
  #   queue (Default nil): Speficies a queue_system(:resque, :delayed_job) for reporting to Innsights
  #   test  (Default false): Used for setting the environment on test mode
  #
  # NOTE: if using delayed_job please check https://github.com/collectiveidea/delayed_job/wiki/Backends 
  # and install the apropiate backend dependency on your application
  
  # config :development do
  #   queue :resque
  #   test  true
  # end
  #
end
