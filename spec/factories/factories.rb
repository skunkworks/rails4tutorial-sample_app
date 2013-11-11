FactoryGirl.define do
  factory :user do
    name                  'Richard Shin'
    email                 'richard@richardshin.com'
    password              'foobar'
    password_confirmation 'foobar'
  end
end