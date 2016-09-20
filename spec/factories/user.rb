FactoryGirl.define do
  factory :user do
    first_name "firstname"
    last_name "lastname"
    email "user@user.com"
    password "password"

    trait :admin do
      role "admin"
    end

    trait :author do
      role "author"
    end

  end
end