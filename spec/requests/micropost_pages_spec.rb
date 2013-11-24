require 'spec_helper'

describe 'Micropost' do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe 'creation' do
    before { visit root_path }

    context 'with valid information' do
      it 'creates a new micropost' do
        fill_in 'micropost_content', with: 'A new post'
        expect{ click_button 'Post' }.to change(Micropost, :count).by(1)
      end
    end

    context 'with invalid information' do
      it 'does not create a new micropost' do
        expect { click_button 'Post' }.not_to change(Micropost, :count)
      end

      describe 'error messages' do
        before { click_button 'Post' }
        it { should have_content('error') }
      end
    end
  end

  describe 'destruction' do
    context 'as current user' do
      before do
        FactoryGirl.create(:micropost, user: user, content: 'Lorem ipsum')
        visit root_path
      end

      it 'deletes a micropost' do
        expect{ click_link 'delete' }.to change(Micropost, :count).by(-1)
      end
    end
  end

end