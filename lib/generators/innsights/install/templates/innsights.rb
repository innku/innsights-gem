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
  
end