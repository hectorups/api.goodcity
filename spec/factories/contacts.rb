# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contact do
    name { Faker::Name.name }
    mobile { generate(:mobile) }
  end
end
