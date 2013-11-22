require 'spec_helper'

describe "User pages" do

	subject { page }

  describe 'profile page' do
    let (:user) { FactoryGirl.create(:user) }

    before { visit user_path(user) }

    it { should have_text(user.name) }
    it { should have_title(user.name) }
  end

  describe 'signup' do
    before { visit signup_path }
    let (:submit) { "Create my account" }

    context 'with invalid information' do
      it 'does not create new user' do
        expect{ click_button(submit) }.not_to change(User, :count)
      end

      describe 'after submission' do
        before { click_button(submit) }

        it { should have_title('Sign up') }
        it { should have_content("error") }
      end
    end

    context 'with valid information' do
      before do
        fill_in 'Name',             with: "Example User"
        fill_in 'Email',            with: "example@example.com"
        fill_in 'Password',         with: "foobar"
        fill_in 'Confirm password', with: "foobar"
      end

      it 'creates a new user' do
        expect{ click_button(submit) }.to change(User, :count).by(1)
      end

      describe 'after saving the user' do
        before { click_button(submit) }
        let (:user) { User.find_by_email("example@example.com") }

        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        it { should have_link('Sign out') }
      end
    end
  end
end
