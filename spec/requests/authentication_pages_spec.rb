require 'spec_helper'

describe "AuthenticationPages" do
  subject {page}

  describe "signin page" do
    before{visit signin_path}

    it{should have_selector('h1',text:"Sign in")}
    it{should have_selector('title',text:"Sign in")}


    describe "with invalid information" do
      before{click_button "Sign in"}

      it{should have_selector('title',text:"Sign in")}
      it{should have_error_message('Invalid')}

      describe "after visiting another page" do
        before{click_link "Home"}
        it {should_not have_selector('div.alert.alert-error')}
      end
    end

    describe "with valid information" do
      let(:user){FactoryGirl.create(:user)}
      before{sign_in(user)}

      it{should have_selector('title',text:user.name)}
      it{should have_link('Profile',href:user_path(user))}
      it{should have_link('Sign out',href:signout_path)}
      it{should_not have_link('Sign in',href:signin_path)}
      it{should have_link('Setting',href:edit_user_path(user))}
      it{should have_link('Users',href:users_path)}

      describe "followed by signout" do
        before{click_link('Sign out')}
        it{should have_link('Sign in')}
      end
    end
  end

  describe "authorization" do
      
    describe "for non-signed-in users" do
      let(:user){FactoryGirl.create(:user)}

      describe "home links" do
        before{visit root_path}
        it{should_not have_link('Profile',href:user_path(user))}
        it{should_not have_link('Sign out',href:signout_path)}
        it{should have_link('Sign in',href:signin_path)}
        it{should_not have_link('Setting',href:edit_user_path(user))}
        it{should_not have_link('Users',href:users_path)}
      end

      describe "when attempt to cisit a protected page" do
        before do
          sign_in user
          visit edit_user_path(user)
        end

        describe "after signining" do
          it "should render the desired protected page" do
            page.should have_selector('title',text:"Edit user")
          end
        end
      end

      describe "in the User controller" do
        
        describe "visiting the edit page" do
          before{visit edit_user_path(user)}
          it{should have_selector('title',text:"Sign in")}
        end

        describe "submitting to the update action" do
          before{put user_path(user)}
          specify{response.should redirect_to(signin_path)}
        end

        describe "visit the user index" do
          before{visit users_path}
          it{should have_selector('title',text:"Sign in")}
        end
      end

      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before{post microposts_path}
          specify{response.should redirect_to(signin_path)}
        end

        describe "submiiting to the destroy action" do
          before{delete micropost_path(FactoryGirl.create(:micropost))}
          specify{response.should redirect_to(signin_path)}
        end
      end
    end

    describe "as wrong user" do
      let(:user){FactoryGirl.create(:user)}
      let(:wrong_user){FactoryGirl.create(:user,email:"wrong@example.com")}
      before{sign_in user}

      describe "visiting Users#edit page" do
        before{visit edit_user_path(wrong_user)}
        it{should_not have_selector('title',text:full_title('Edit user'))}
      end

      describe "submitting a PUT request to the User#update action" do
        before{put user_path(wrong_user)}
        specify{response.should redirect_to(root_path)}
      end

    end

    describe "as non-admin user" do
      let(:user){FactoryGirl.create(:user)}
      let(:non_admin){FactoryGirl.create(:user)}

      before{sign_in non_admin}

      describe "submitting delete request to the User#destory" do
        before{delete user_path(user)}
        specify{response.should redirect_to(root_url)}
      end
    end

    describe "signed-in user" do
      let(:user){FactoryGirl.create(:user)}
      before{sign_in user}

      describe "when visit User#new" do
        before{visit signup_path}
        it{should have_selector('title',text:full_title(''))}
      end

      describe "when post User#create" do
        before{post users_path(user)}
        specify{response.should redirect_to root_path}
      end

    end

  end



end
