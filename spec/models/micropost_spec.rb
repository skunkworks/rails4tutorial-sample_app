require 'spec_helper'

describe Micropost do
  let(:user) { FactoryGirl.create(:user) }
  # FactoryGirl ends up creating a new user if a user isn't specified
  let(:micropost) { FactoryGirl.create(:micropost, user: user, created_at: 1.day.ago) }
  
  subject { micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }

  it { should be_valid }
  its(:user) { should eq user }

  context 'when user id is not present' do
    before { micropost.user_id = nil }
    it { should_not be_valid }
  end

  context 'with blank content' do
    before { micropost.content = ' ' }
    it { should_not be_valid }
  end

  context 'with content more than 140 characters' do
    before { micropost.content = 'a'*141 }
    it { should_not be_valid }
  end
end
