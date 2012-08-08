class DudesController < ApplicationController 
  respond_to :json
  def index
    Dude.create
    respond_with a: nil
  end

  def new
    respond_with a: nil
  end

  def create
    Dude.create
    respond_with a: nil
  end
  
  def current_dude
    Dude.first
  end
end
