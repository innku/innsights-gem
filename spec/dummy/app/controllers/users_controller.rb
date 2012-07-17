class UsersController < ApplicationController 
  respond_to :json
  def index
    User.create
    respond_with a: nil
  end

  def new
    respond_with a: nil
  end

  def create
    User.create
    respond_with a: nil
  end
  
  def current_user
    User.first
  end
end
