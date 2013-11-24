require 'spec_helper'
$count = 0
describe User do

  # FactoryGirl.build vs .create - new vs create
  let (:user) { FactoryGirl.build(:user) }
  subject { user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }

  it { should be_valid }
  it { should_not be_admin }

  context "when name is not present" do
    before { user.name = " " }
    it { should_not be_valid }
  end

  context "when email is not present" do
  	before { user.email = "" }
  	it { should_not be_valid }
  end

  context "when name is too long" do
  	before { user.name = "a" * 51 }
  	it { should_not be_valid }
	end

	context "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).not_to be_valid
      end
    end
  end

  context "when the email address is already taken" do
  	before do
  		user_with_same_email = user.dup
      user_with_same_email.email = user.email.upcase
      user_with_same_email.save
    end

  	it { should_not be_valid }
  end

  context "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to be_valid
      end
    end
  end

  context "when email address is mixed case" do
  	let (:mixed_case_email) { "Foo@ExAMPle.CoM" }

  	it "should be saved as all lower-case" do
  		user.email = mixed_case_email
  		user.save
  		expect(user.email).to eq mixed_case_email.downcase
  	end
  end

  context "when password is not present" do
  	before do
  		user.password = " "
  		user.password_confirmation = " "
  	end

  	it { should_not be_valid }
  end

  context "when the password and password confirmation don't match" do
  	before do
  		user.password_confirmation = "not foobar"
  	end

  	it { should_not be_valid }
  end

  context "with a password that's too short" do
  	before { user.password = user.password_confirmation = "a" * 5 }
  	it { should be_invalid }
  end

  describe "return value of authenticate method" do
  	before { user.save }
  	let(:found_user) { User.find_by(email: user.email) }

  	context "with valid password" do
  		it { should eq found_user.authenticate(user.password) }
  	end

  	context "with invalid password" do
  		let(:user_for_invalid_password) { found_user.authenticate("invalid") }
  		it { should_not eq user_for_invalid_password }
  		specify { expect(user_for_invalid_password).to be_false }
  	end
  end

  describe 'remember token' do
    before { user.save }
    its(:remember_token) { should_not be_blank }
  end

  context 'with admin attribute set to true' do
    before do
      user.save!
      user.toggle!(:admin)
    end

    # Rails (ActiveRecord) smart enough to create User#admin? because the database
    # has a boolean admin field.
    it { should be_admin }
  end

  describe 'microposts association' do
    before { user.save }
    let! (:oldest_micropost) { FactoryGirl.create(:micropost, user: user, created_at: 1.day.ago) }
    let! (:newer_micropost)  { FactoryGirl.create(:micropost, user: user, created_at: 1.hour.ago) }

    it "returns the user's microposts by creation time descending" do
      # Note the clever to_a to allow us to compare our expected Array to the AR collection
      expect(user.microposts.to_a).to eq([newer_micropost, oldest_micropost])
    end

    it "destroys associated microposts" do
      microposts = user.microposts.to_a
      user.destroy
      # This line is from the book. It seems wacky at first because in-memory representations of AR
      # objects are not nilled out by calling destroy on them, so it seems redundant to make sure
      # that microposts is not empty. However, ActiveRecord lazy queries the database, so if microposts
      # isn't evaluated until after #destroy, it will return empty. We protect against that condition
      # by calling to_a on microposts and by testing explicitly.
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.find_by_id(micropost.id)).to be_nil
      end
    end

    describe 'status' do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end

      its(:feed) { should include oldest_micropost }
      its(:feed) { should include newer_micropost }
      its(:feed) { should_not include unfollowed_post }
    end
  end
end