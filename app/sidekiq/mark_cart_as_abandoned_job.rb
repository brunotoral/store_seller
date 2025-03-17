class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    abandoned_carts = Cart.active.where('last_interaction_at < ?', 3.hours.ago)
    if abandoned_carts.any?
      abandoned_carts_count = abandoned_carts.count
      ActiveRecord::Base.transaction do
        abandoned_carts.update_all(status: :abandoned)
      end

      log_info("Successfully marked #{abandoned_carts_count} carts as abandoned.")
    end

    log_info('No abandoned carts found.')
  end

  private

    def log_info(message)
      Rails.logger.info "#{self.class}: #{message}"
    end
end
