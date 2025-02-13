# frozen_string_literal: true

class AddLastInteractionAndAbandonedToCart < ActiveRecord::Migration[7.1]
  def change
    change_table :carts, bulk: true do |t|
      t.datetime :last_interaction_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.boolean :abandoned, default: false, null: false
    end
  end
end
