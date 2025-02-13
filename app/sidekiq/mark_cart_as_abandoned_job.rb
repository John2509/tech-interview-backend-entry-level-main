require 'sidekiq-scheduler'

class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    Cart.all.each do |cart|
      if cart.abandoned?
        cart.remove_if_abandoned
      else
        cart.mark_as_abandoned
        cart.save
      end
    end
  end
end
