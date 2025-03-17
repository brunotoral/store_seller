class CartItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :quantity, :unit_price, :total_price

  def id
    object.product_id
  end

  def name
    object.product.name
  end

  def unit_price
    object.unit_purchase_price
  end

  def total_price
    object.total_price
  end
end
