require 'spec_helper'

describe "User pages" do

	subject { page }

  describe 'profile page' do
    let (:user) { FactoryGirl.create(:user) }
    let! (:m1) { FactoryGirl.create(:micropost, user: user, content: 'Lorum ipsum') }
    let! (:m2) { FactoryGirl.create(:micropost, user: user, content: 'Party hardy') }
    before { visit user_path(user) }

    it { should have_text(user.name) }
    it { should have_title(user.name) }

    describe 'microposts' do
      it { should have_content "#{user.microposts.count}" }
      it { should have_content m1.content }
      it { should have_content m2.content }
    end
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

        it { should have_title 'Sign up' }
        it { should have_error_message 'error' }
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
        it { should have_success_message 'Welcome' }
        it { should have_link 'Sign out', href: signout_path }
      end
    end
  end

  describe 'edit' do
    let (:user) { FactoryGirl.create(:user) }
    before do
      sign_in(user)
      visit edit_user_path(user)
    end

    describe 'page' do
      # Describe the page title, content, and link to change gravatar
      it { should have_title 'Edit user' }
      it { should have_content 'Update your profile' }
      it { should have_link 'Change', href: 'http://gravatar.com/emails'}
    end

    context 'with invalid information' do
      before do
        click_button 'Save changes'
      end

      # Test that it doesn't change the user in the database?

      context 'after submission' do
        it { should have_error_message 'error'}
      end
    end

    context 'with valid information' do
      let (:new_name) { 'John Smith' }
      let (:new_email) { 'johnsmith@test.com' }

      before do
        fill_in 'Name',             with: new_name
        fill_in 'Email',            with: new_email
        fill_in 'Password',         with: user.password
        fill_in 'Confirm password', with: user.password
        click_button 'Save changes'
      end

      it { should have_success_message }
      it { should have_title new_name }
      it { should have_link 'Sign out', href: signout_path }

      specify { expect(user.reload.name ).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end

    describe 'forbidden attributes' do
      let (:params) do
        { user: { admin: true } }
      end

      before do
        sign_in user, no_capybara: true
        patch user_path(user), params
      end

      specify { expect(user.reload).not_to be_admin }
    end
  end

  describe 'index' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in(user)
      visit users_path
    end
    
    it { should have_title 'All users' }
    it { should have_text 'All users' }

    describe 'pagination' do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }

      it { should have_selector('div.pagination') }

      it 'lists each user' do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe 'delete links' do
      before do
        sign_in(user)
        visit users_path
      end

      it { should_not have_link('delete') }

      context 'as an admin user' do
        let (:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in(admin)
          visit users_path
        end
      
        it { should have_link('delete', href: user_path(User.first)) }
        it "successfully deletes users" do
          expect { click_link('delete', match: :first) }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
    
  end
end
