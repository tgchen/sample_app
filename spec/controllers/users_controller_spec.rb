require 'spec_helper'

describe UsersController do
  render_views
  
  #Describe show user profile testing
  describe "Get" 'index' do
    describe "for non-signed in user" do
      it "should deny access" do
        get :index    
        response.should redirect_to(signin_path) 
      end
   end
   
    describe "for signed in user" do
     before(:each) do
       @user = test_sign_in(Factory(:user))
       Factory(:user, :email =>"another@example.com")
       Factory(:user, :email =>"theistest@example.com")
       
       30.times do
       Factory(:user, :email => Factory.next(:email))
      end
     end
     
     
     it "should be success full" do
       get :index
       response.should be_success
     end
      it "should have the right title" do
        get :index
        response.should have_selector('title', :content => "All users")
      end
      
      it "should have element of each user" do
        get :index
        User.paginate(:page =>1 ).each do |user|
        response.should have_selector('li', :content =>user.name)
        end
      end
      it "should paginate user" do
        get :index
        response.should have_selector('div.pagination')
        response.should have_selector('span.disabled', :content => "Previous")
        response.should have_selector('a', :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector('a', :href => "/users?page=2",
                                           :content => "Next")
      end
      it "should have a delete link for admin" do
        @user.toggle(:admin)
        other_user=User.all.second
        get :index
        response.should have_selector('a', :href => user_path(other_user),
                                           :content => "delete")
      end
      
      it "should not have a delete link for admin" do
       
        other_user=User.all.second
        get :index
        response.should_not have_selector('a', :href => user_path(other_user),
                                           :content => "delete")
      end
   end
end
  
  describe "Get 'show'" do
    
    before(:each) do
      @user =Factory(:user)
    end
    
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end
    
    it "should find the right user" do
       get :show, :id => @user
       assigns(:user).should == @user
    end
    
    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector('title', :content => @user.name)
    end
    
    it "should have the user name" do
      get :show, :id => @user
      response.should have_selector('h1', :content => @user.name)
    end
    
    it "should have a profile image" do
      get :show, :id =>@user
      response.should have_selector('h1>img', :class => "gravatar")
    end
    
    it "should have the right URL " do
      get :show, :id => @user
      response.should have_selector('td>a', :content => user_path(@user),
                                            :href  => user_path(@user)) 
    end
    
    
  end
  #Describe get new user page testing
  describe "GET 'new'" do
    
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do 
      get :new
      response.should have_selector('title', :content => "Sign up")
    end 
  end
  
  #Describe create new user testing
  describe "Post 'create" do
    
    describe "failure" do
      
      before(:each) do
        @attr = {:name => "", :email => "", 
                 :password => "", :password_confirmation =>""}
      end
      
      it "should have the right title" do
        post :create, :user =>@attr
        response.should have_selector('title', :content => "Sign up")  
      end
      
      it "should redner the new page" do
        post :create, :user =>@attr
        response.should render_template('new')
        
      end
      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
    end
    
    describe "success" do
      
      before(:each) do
        @attr = {:name => "New User", :email => "user@example.com", 
                 :password => "foobar", :password_confirmation =>"foobar"}
      end
      
     it "should create a user " do
       lambda do
         post :create, :user => @attr
       end.should change(User, :count).by(1)
      end
     it "shoud redirect user to show page" do
       post :create, :user =>@attr
       response.should redirect_to(user_path(assigns(:user)))
     end
     
     it "should have a welcome message"do
        post :create, :user =>@attr
        flash[:success].should =~ /welcome to the sample app/i       
    end
    
    it "should sign user in" do
      post :create, :user => @attr
      controller.should be_signed_in  
    end
   end
  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      @user= Factory(:user)
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end
    
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector('title', :content => "Edit user")
    end
    it "should have a link to change gravatar" do
      get :edit, :id => @user
      response.should have_selector('a', :href => 'http://gravatar.com/emails',
                                         :content => "change")
    end
  end
  
  describe "PUT 'update'" do
    
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    describe "failure" do
      before(:each) do
         @attr = {:name => "", :email => "", 
                 :password => "", :password_confirmation =>""}
      end
      it "should re-render the edit page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end
      
      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector('title', :content => "Edit user")
      end
    end
    
    describe "success" do
      
      before(:each) do
        @attr= {:name => "new name", :email => "new@example.com", 
                :passwod => "barbar", :password_confirmation => "barbar"}
      end
      
      it "should change the user's attribute" do
         put :update, :id => @user, :user => @attr
         user = assigns(:user)
         @user.reload
         @user.should == user
      end
    end
  end
  
    describe "authentication of edit/update action" do
      
      before(:each) do
        @user = Factory(:user)
      end
      
      describe "for Non-Signed in User" do
        
        it "should deny access to 'edit" do
          
        get :edit, :id =>@user
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
        
        end
      
        it "should deny access to update" do
          
        put :update, :id =>@user, :user =>{}
        response.should redirect_to(signin_path)
        
        end
     end
      
      describe "for Signed in user" do
        before(:each) do
          wrong_user= Factory(:user, :email => "wronguser@exampee.com")
          test_sign_in(wrong_user)
        end
        
        it "should require matching users for 'edit" do
          get :edit, :id =>@user
          response.should redirect_to(root_path)
        end
        
        it "" do
          put :update, :id =>@user, :@user =>{}
          response.should redirect_to(root_path)
        end
        
      end
     
      
    end
    
    describe "DELETE 'destroy'" do
     before(:each)do
      @user=Factory(:user)
     end
     describe "as a non-sign in user" do
       it "should deny access" do
         delete :destroy, :id =>@user
         response.should redirect_to(signin_path)
       end
     end
     
     describe "as non-admin user" do
       it "should protect action" do
         test_sign_in(@user)
         delete :destroy, :id =>@user
         response.should redirect_to(root_path)
       end

     end
     describe "as admin user" do
       before(:each) do
         @admin = Factory(:user, :email => "admin@example.com", :admin => true)
         test_sign_in(@admin)
       end
       
       it "should destroy user" do
         lambda do
           delete :destroy, :id => @user
         end.should change(User, :count).by(-1)  
       end
       it "should redirect to user page" do
         delete :destroy, :id =>@user
         flash[:success].should =~ /destroyed/i
         response.should redirect_to(user_path)
       end
       
       it "" do
         lambda do
           delete :destroy, :id =>@admin
         end.should_not change(User, :count)
         
         
       end
     end
     
     
   end
  
  
  
end