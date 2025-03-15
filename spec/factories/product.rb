# frozen_string_literal: true

FactoryBot.define do
   factory :product do
     name { Faker::Commerce.product_name }
     price { Faker::Number.decimal }
   end
end
