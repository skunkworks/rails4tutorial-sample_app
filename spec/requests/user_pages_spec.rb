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
    end

    context 'with valid information' do
      before do
        fill_in 'Name', with: "Example User"
        fill_in 'Email', with: "example@example.com"
        fill_in 'Password', with: "foobar"
        fill_in 'Confirm password', with: "foobar"
      end

      it 'creates a new user' do
        expect{ click_button(submit) }.to change(User, :count).by(1)
      end
    end
  end
end
