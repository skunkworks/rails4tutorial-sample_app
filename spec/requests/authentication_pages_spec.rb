require 'spec_helper'

describe "Authentication" do
  subject { page }

  describe 'sign-in page' do
    before { visit signin_path }

    it { should have_title   'Sign in'}
    # A better test -- specify that we want an h1 element with 'Sign in'
    it { should have_selector 'h1', text: 'Sign in' }

  end

  describe 'sign-in' do
    context 'with valid information' do
      let (:user) { FactoryGirl.create(:user) }

      before { sign_in(user) }

      it { should have_title user.name }
      # capybara's have_link method is new to me. Specify href with :href
      it { should have_link 'Profile',  href: user_path(user) }
      it { should have_link 'Users', href: users_path }
      it { should have_link 'Settings', href: edit_user_path(user) }
      it { should have_link 'Sign out', href: signout_path }
      it { should_not have_link 'Sign in', href: signin_path }

      context 'followed by sign-out' do
        before { click_link 'Sign out' }
        
        it { should have_link 'Sign in' }
        it { should_not have_link 'Sign out' }
        it { should_not have_link 'Users' }
        it { should_not have_link 'Settings' }
        it { should_not have_link 'Profile' }
      end
    end

    context 'with invalid information' do
      before do
        visit signin_path
        click_button 'Sign in'
      end

      it { should have_title 'Sign in' }
      it { should have_error_message 'Invalid' }

      context 'after visiting another page' do
        it 'does not display a sign-in error message' do
          click_link 'Home'
          expect(page).not_to have_selector 'div.alert.alert-error'
        end
      end
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        # Note: this is fucking killing me how this tutorial mixes up different
        # kinds of tests (model, controller, integration/request) together in a
        # haphazard, confusing way. Checking the response should occur as a
        # controller test; in a request/integration test, you should be testing
        # the results of the page that's rendered. I understand that it's easier
        # to not have to explain that, but I just wasted 15 minutes trying to
        # figure out why doing visit users_path would cause response to be nil.
        # It's because you can't check the HTTP response by doing visit. You have
        # to perform the HTTP verb instead.
        describe "visiting the user index" do
          before { get users_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting a DELETE request to UsersController#destroy" do
          before { delete user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      context 'as a non-admin user' do
        let (:non_admin) { FactoryGirl.create(:user) }
        before do
          sign_in non_admin, no_capybara: true
          visit users_path
        end

        describe "submitting a DELETE request to UsersController#destroy" do
          before { delete user_path(user) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end

      context 'when attempting to visit a protected page' do
        before { visit edit_user_path(user) }

        context 'after signing in' do
          before do
            fill_in 'Email', with: user.email
            fill_in 'Password', with: user.password
            click_button 'Sign in'
          end

          it 'forwards you to the correct location' do
            expect(page).to have_title 'Edit user'
          end
        end
      end
    end

    describe 'as wrong user' do
      let (:user) { FactoryGirl.create(:user) }
      # Need to remember that you can alter the factory object attributes this way!
      let (:wrong_user) { FactoryGirl.create(:user, email: "wronguser@test.com") }
      before { sign_in user, no_capybara: true }

      describe "submitting a GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_path) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_path) } 
      end
    end

  end

end
