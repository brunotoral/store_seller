
class RemoveAbandonedCartJob
  include Sidekiq::Job

  def perform
    carts_to_remove = Cart.abandoned.where('last_interaction_at < ?', 7.days.ago)
    if carts_to_remove.any?
      carts_count = carts_to_remove.count
      ActiveRecord::Base.transaction do
        carts_to_remove.destroy_all
      end

      log_info("Successfully destroyed #{carts_count} abandoned carts.")
    end

    log_info('No abandoned carts to remove found.')
  end

  private

    def log_info(message)
      Rails.logger.info "#{self.class}: #{message}"
    end
end
