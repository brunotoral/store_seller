FactoryBot.define do
  factory :cart_item do
    cart { association :shopping_cart }
    product { association :product }
    unit_purchase_price { product.price }
    quantity { 1 }
  end
end
