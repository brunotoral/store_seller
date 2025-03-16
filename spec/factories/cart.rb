# frozen_string_literal: true

FactoryBot.define do
   factory :cart, aliases: [:shopping_cart] do
     total_price { 0 }
     last_interaction_at { Time.current }
   end
end
