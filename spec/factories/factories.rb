FactoryGirl.define do
  factory :user do
    sequence(:name)       { |n| "Person #{n}" }
    sequence(:email)      { |n| "person_#{n}@railstutorial.com" }
    password              'foobar'
    password_confirmation 'foobar'

    factory :admin do
      admin true
    end
  end

  factory :micropost do
    content 'Lorum ipsum'
    user # Creates a new user and associates it with this micropost
  end
end