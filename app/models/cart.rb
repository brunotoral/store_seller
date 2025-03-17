# frozen_string_literal: true

class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :last_interaction_at, presence: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  enum status: { active: 0, abandoned: 1, finished: 2 }

  def mark_as_abandoned?
    active? && last_interaction_at < 3.hours.ago
  end

  def mark_as_abandoned
    abandoned! if mark_as_abandoned?
  end

  def remove_if_abandoned
    destroy if abandoned?
  end

  def should_delete?
    last_interaction_at < 7.days.ago
  end

  def calculate_total_price
    cart_items.sum(&:total_price)
  end
end
