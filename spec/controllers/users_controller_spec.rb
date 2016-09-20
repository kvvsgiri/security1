require 'rails_helper'

def check_get_out
  expect(response).to redirect_to(:root)
  expect(session[:user_id]).to eq(nil)
  expect(flash[:notice]).to eq("Something Fishy!!!")
end

def set_login(user)
  session[:user_id] = user.id
end

RSpec.describe UsersController do
  before(:each) do
    @admin = create(:user, :admin,  first_name: "admin", email: "admin@security.com", password: Digest::MD5.hexdigest("admin"))
    @user1 = create(:user, :author, first_name: "user1", email: "user1@security.com", password: Digest::MD5.hexdigest("user1"))
    @user2 = create(:user, :author, first_name: "user2", email: "user2@security.com", password: Digest::MD5.hexdigest("user2"))
  end

  after(:each) do
    #DatabaseCleaner.clean
  end

  describe "GET #index" do
    ## For User index page
    it "should load users index page for admin" do
      set_login(@admin)
      get :index
      puts @admin.inspect
      expect(response).to render_template(:index)
    end

    it "should logout and go to login page if normal user try to load users index page" do
      set_login(@user1)
      get :index
      check_get_out
    end

    ## For User Show page
    it "should load the show user page of self for admin" do
      set_login(@admin)
      get :show, id: @admin.id
      expect(response).to render_template(:show)
    end

    it "should load the show user page of other user for admin" do
      set_login(@admin)
      get :show, id: @user1.id
      expect(response).to render_template(:show)
    end

    it "should load the show user page of self for normal user" do
      set_login(@user1)
      get :show, id: @user1.id
      expect(response).to render_template(:show)
    end

    it "should logout and go to login page if normal user try to load show user page of other user" do
      set_login(@user1)
      get :show, id: @user2.id
      check_get_out
    end

    ## For User New page
    it "should load the new user page of for admin" do
      set_login(@admin)
      get :new
      expect(response).to render_template(:new)
    end

    it "should logout and go to login page if normal user try to load new user page" do
      set_login(@user1)
      get :new
      check_get_out
    end

    ## For User Create
    it "should create new user for admin" do
      set_login(@admin)
      post :create, {format: "html", user: {first_name: "giri", email: "giri@kreatio.com", password: "giri", role: "admin"}}
      new_user = User.find_by_email("giri@kreatio.com")
      expect(new_user.first_name).to eq("giri")
      expect(response).to redirect_to(user_path(new_user))
    end

    it "should logout and go to login page if normal user try to create new user" do
      set_login(@user1)
      post :create, {format: "html", user: {first_name: "giri", email: "giri@kreatio.com", password: "giri", role: "admin"}}
      check_get_out
    end

    ## For User Edit
    it "should load edit page of self for admin" do
      set_login(@admin)
      get :edit, id: @admin.id
      expect(response).to render_template(:edit)
    end

    it "should load edit page of other user for admin" do
      set_login(@admin)
      get :edit, id: @user1.id
      expect(response).to render_template(:edit)
    end

    it "should load edit page of self for normal user" do
      set_login(@user1)
      get :edit, id: @user1.id
      expect(response).to render_template(:edit)
    end

    it "should logout and go to login page if normal user try to load edit page of other user" do
      set_login(@user1)
      get :edit, id: @user2.id
      check_get_out
    end

    ## For User Update
    it "should update the user record of self for admin" do
      set_login(@admin)
      put :update, {id: @admin.id, user: {first_name: "admin1", email: "admin1@kreatio.com", role: "author"}}
      expect(response).to redirect_to(user_path(@admin))
      @admin.reload
      expect(@admin.first_name).to eq("admin1")
      expect(@admin.email).to eq("admin1@kreatio.com")
      expect(@admin.role).to eq("author")
      expect(flash[:notice]).to eq("User was successfully updated.")
    end

    it "should update the user record of other user for admin" do
      set_login(@admin)
      put :update, {id: @user1.id, user: {first_name: "user111", email: "user111@kreatio.com", role: "admin"}}
      expect(response).to redirect_to(user_path(@user1))
      @user1.reload
      expect(@user1.first_name).to eq("user111")
      expect(@user1.email).to eq("user111@kreatio.com")
      expect(@user1.role).to eq("admin")
      expect(flash[:notice]).to eq("User was successfully updated.")
    end

    it "should update the user record of self for normal user" do
      set_login(@user1)
      put :update, {id: @user1.id, user: {first_name: "user111", email: "user111@kreatio.com"}}
      expect(response).to redirect_to(user_path(@user1))
      @user1.reload
      expect(@user1.first_name).to eq("user111")
      expect(@user1.email).to eq("user111@kreatio.com")
      expect(flash[:notice]).to eq("User was successfully updated.")
    end

    it "should not allow to update the user record of other user for normal user" do
      set_login(@user2)
      put :update, {id: @user1.id, user: {first_name: "user111", email: "user111@kreatio.com"}}
      check_get_out
    end

    it "should not update role and password of self for normal user" do
      set_login(@user1)
      put :update, {id: @user1.id, user: {first_name: "user111", email: "user111@kreatio.com", role: "admin", password: "new_password"}}
      expect(response).to redirect_to(user_path(@user1))
      @user1.reload
      expect(@user1.first_name).to eq("user111")
      expect(@user1.email).to eq("user111@kreatio.com")
      expect(@user1.role).to eq("author")
      expect(@user1.password).to eq(Digest::MD5.hexdigest("user1"))
      expect(flash[:notice]).to eq("User was successfully updated.")
    end

    ## For Change password page
    it "should load the change password page of self for admin" do
      set_login(@admin)
      get :change_password, id: @admin.id
      expect(response).to render_template(:change_password)
    end

    it "should load the change password page of other user for admin" do
      set_login(@admin)
      get :change_password, id: @user1.id
      expect(response).to render_template(:change_password)
    end

    it "should load the change password page of self for normal user" do
      set_login(@user1)
      get :change_password, id: @user1.id
      expect(response).to render_template(:change_password)
    end

    it "should logout and go to login page if normal user try to load change_password page of other user" do
      set_login(@user1)
      get :change_password, id: @user2.id
      check_get_out
    end

    ## For Update password page
    it "should be able to update password of self for admin" do
      set_login(@admin)
      post :update_password, id: @admin.id, new_password: "new_password"
      expect(response).to redirect_to(users_path)
      @admin.reload
      expect(@admin.password).to eq(Digest::MD5.hexdigest("new_password"))
    end

    it "should be able to update password of other users for admin" do
      set_login(@admin)
      post :update_password, id: @user1.id, new_password: "new_password"
      expect(response).to redirect_to(users_path)
      @user1.reload
      expect(@user1.password).to eq(Digest::MD5.hexdigest("new_password"))
    end

    it "should be able to update password of self for normal user if proper details are given" do
      set_login(@user1)
      post :update_password, id: @user1.id, old_password: "user1", new_password: "new_password", confirm_password: "new_password"
      expect(response).to redirect_to(user_path(@user1))
      @user1.reload
      expect(@user1.password).to eq(Digest::MD5.hexdigest("new_password"))
    end

    it "should be not able to update password of self for normal user if old password is wrong" do
      set_login(@user1)
      post :update_password, id: @user1.id, old_password: "user11", new_password: "new_password", confirm_password: "new_password"
      expect(response).to render_template(:change_password)
      @user1.reload
      expect(@user1.password).to eq(Digest::MD5.hexdigest("user1"))
    end

    it "should be not able to update password of self for normal user if new password and confirm password does not match" do
      set_login(@user1)
      post :update_password, id: @user1.id, old_password: "user1", new_password: "new_password", confirm_password: "new_password1"
      expect(response).to render_template(:change_password)
      @user1.reload
      expect(@user1.password).to eq(Digest::MD5.hexdigest("user1"))
    end

    it "should logout and go to login page if normal user try to update password of other user" do
      set_login(@user1)
      post :update_password, id: @user2.id, old_password: "user2", new_password: "new_password", confirm_password: "new_password1"
      check_get_out
      @user2.reload
      expect(@user2.password).to eq(Digest::MD5.hexdigest("user2"))
    end

  end
end
