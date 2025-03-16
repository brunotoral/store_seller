class AddUnitPurchasePrinceToCartItems < ActiveRecord::Migration[7.1]
  def change
    add_column :cart_items, :unit_purchase_price, :decimal, precision: 17, scale: 2, null: false, default: 0
  end
end
