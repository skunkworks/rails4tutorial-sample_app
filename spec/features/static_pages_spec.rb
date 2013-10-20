require 'spec_helper'

feature "StaticPages" do

	scenario "User visits the Home page" do
		visit '/static_pages/home'
		expect(page).to have_text('Sample App')
		expect(page).to have_title('Ruby on Rails Tutorial Sample App | Home')
	end

	scenario "User visits the Help page" do
		visit '/static_pages/help'
		expect(page).to have_text('Help')
		expect(page).to have_title('Ruby on Rails Tutorial Sample App | Help')
	end

	scenario "User visits the About page" do
		visit '/static_pages/about'
		expect(page).to have_text('About Us')
		expect(page).to have_title('Ruby on Rails Tutorial Sample App | About Us')
	end
end