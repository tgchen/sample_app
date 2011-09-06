require 'spec_helper'

describe SessionsController do
  render_views
  describe "GET 'new'" do
    
    it "should successful" do
      get :new
      response.should be_success
    end
    
    it "should the right title" do
      get :new
      response.should have_selector('title', :content => "Sign in")
    end
  end

end
