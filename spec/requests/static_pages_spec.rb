require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let (:heading)    { 'Sample App' }
    let (:page_title) { '' }

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }

    context 'when signed in' do
      let (:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: 'Lorem ipsum')
        sign_in user
        visit root_path
      end

      it "renders a user's feed" do
        user.feed.each do |feed_item|
          expect(page).to have_selector("li##{feed_item.id}", text: feed_item.content)
        end
      end

      describe 'sidebar' do
        context "when the user has one micropost" do
          it 'has the correct count and pluralization' do
            expect(page).to have_selector('aside section', text: '1 micropost')
          end
        end
        
        context 'when the user has multiple microposts' do
          before do
            FactoryGirl.create(:micropost, user: user, content: 'Dolor sit amet')
            visit root_path
          end

          it 'has the correct count and pluralization' do
            expect(page).to have_selector('aside section', text: '2 microposts')
          end
        end
      end

      describe 'micropost pagination' do
        before do
          30.times { FactoryGirl.create(:micropost, user: user) }
          visit root_path
        end

        it { should have_selector('div.pagination') }
        
        it 'lists each micropost' do
          Micropost.paginate(page: 1).each do |micropost|
            expect(page).to have_selector('li', text: micropost.content)
          end
        end
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let (:heading)    { 'Help' }
    let (:page_title) { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let (:heading)    { 'About Us' }
    let (:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let (:heading)    { 'Contact' }
    let (:page_title) { 'Contact' }

    it_should_behave_like "all static pages"
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title(full_title('About Us'))
    click_link "Help"
    expect(page).to have_title(full_title('Help'))
    click_link "Contact"
    expect(page).to have_title(full_title('Contact'))
    click_link "Home"
    click_link "Sign up now!"
    expect(page).to have_title(full_title('Sign up'))
    click_link "sample app"
    expect(page).to have_title(full_title(''))
  end
end