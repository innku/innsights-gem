class UsersController < ApplicationController 
  respond_to :json
  def index
    respond_with a: nil
  end

  def new
    respond_with a: nil
  end
  
  def current_user
    User.first
  end
end
