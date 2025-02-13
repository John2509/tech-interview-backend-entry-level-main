require 'rails_helper'
RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    subject do
      MarkCartAsAbandonedJob.new.perform
    end

    context 'when there is not an abandoned cart' do
      let!(:active_cart) { Cart.create }

      it 'does not change the active cart' do
        expect { subject }.not_to(change { active_cart.reload })
      end
    end

    context 'when there is a recent abandoned cart' do
      let!(:to_be_abandoned_cart) { Cart.create(last_interaction_at: 3.hours.ago) }

      it 'marks the cart as abandoned' do
        expect { subject }.to change { to_be_abandoned_cart.reload.abandoned? }.from(false).to(true)
      end
    end

    context 'when there is a old abandoned cart' do
      let!(:to_be_removed_cart) { Cart.create(last_interaction_at: 7.days.ago, abandoned: true) }

      it 'removes the cart' do
        expect { subject }.to change { Cart.count }.by(-1)
      end
    end

    context 'when there are multiple carts' do
      let!(:active_cart) { Cart.create }
      let!(:to_be_abandoned_cart) { Cart.create(last_interaction_at: 3.hours.ago) }
      let!(:to_be_removed_cart) { Cart.create(last_interaction_at: 7.days.ago, abandoned: true) }

      it 'performs the appropiate action on each cart' do
        expect { subject }.to  change { to_be_abandoned_cart.reload.abandoned? }.from(false).to(true)
                          .and change { Cart.count }.by(-1)
      end
    end
  end
end
