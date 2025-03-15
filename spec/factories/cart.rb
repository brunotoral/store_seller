# frozen_string_literal: true

FactoryBot.define do
   factory :cart, aliases: [:shopping_cart] do
     total_price { Faker::Number.decimal }
   end
end
