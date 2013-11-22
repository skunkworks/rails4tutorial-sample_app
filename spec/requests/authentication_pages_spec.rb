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
    before { visit signin_path }

    context 'with valid information' do
      let (:user) { FactoryGirl.create(:user) }

      before do
        fill_in 'Email',    with: user.email
        fill_in 'Password', with: user.password
        click_button 'Sign in'
      end

      it { should have_title user.name }
      # capybara's have_link method is new to me. Specify href with :href
      it { should have_link 'Profile', href: user_path(user) }
      it { should have_link 'Sign out', href: signout_path }
      it { should_not have_link 'Sign in', href: signin_path }

      context 'followed by sign-out' do
        before { click_link 'Sign out' }
        
        it { should have_link 'Sign in' }
      end
    end

    context 'with invalid information' do
      before { click_button 'Sign in' }

      it { should have_title 'Sign in' }
      it { should have_selector 'div.alert.alert-error', text: 'Invalid' }

      context 'after visiting another page' do
        it 'does not display a sign-in error message' do
          click_link 'Home'
          expect(page).not_to have_selector 'div.alert.alert-error'
        end
      end
    end
  end
end
