require 'spec_helper'

feature "StaticPages" do

	let(:base_title) { "Ruby on Rails Tutorial Sample App" }

	scenario "User visits the Home page" do
		visit '/static_pages/home'
		expect(page).to have_text('Sample App')
		expect(page).to have_title("#{base_title} | Home")
	end

	scenario "User visits the Help page" do
		visit '/static_pages/help'
		expect(page).to have_text('Help')
		expect(page).to have_title("#{base_title} | Help")
	end

	scenario "User visits the About page" do
		visit '/static_pages/about'
		expect(page).to have_text('About Us')
		expect(page).to have_title("#{base_title} | About Us")
	end

	scenario "User visits the Contact page" do
		visit '/static_pages/contact'
		expect(page).to have_title("#{base_title} | Contact")
	end
end