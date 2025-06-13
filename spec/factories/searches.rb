FactoryBot.define do
  factory :search do
    address { "123 Steet, Town, California" }
    zip_code { "12345" }
    searched_at { Time.now }
    cached { false }

    trait :cached do
      cached { true }
    end

    trait :fresh do
      cached { false }
    end

    trait :recent do
      searched_at { 2.days.ago }
    end

    trait :old do
      searched_at { 10.days.ago }
    end
  end
end
