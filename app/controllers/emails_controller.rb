class EmailsController < ApplicationController

  # GET                   /unsubscribe(.:format)
  def unsubscribe
    Rails.logger.info("Mailgun Unsubscribe: #{params.inspect}")
    if mailgun?(ENV['MAILGUN_API_KEY'], params['token'], params['timestamp'], params['signature'])
      if params[:email_type] == NotifierMailer::WELCOME_EVENT
        user = User.where(email: params[:recipient]).first
        user.update_attribute(:receive_newsletter, false)
      elsif params[:email_type] == NotifierMailer::ACTIVITY_EVENT
        user = User.where(email: params[:recipient]).first
        user.update_attribute(:notify_on_award, false)
      elsif params[:email_type] == NotifierMailer::POPULAR_PROTIPS_EVENT
        # Piggybacking off the old 'weekly_digest' subscription list
        user = User.where(email: params[:recipient]).first
        user.update_attribute(:receive_weekly_digest, false)
      end
    end
    return head(200)
  end

  # GET                   /delivered(.:format)
  def delivered
    Rails.logger.info("Mailgun Delivered: #{params.inspect}")
    if mailgun?(ENV['MAILGUN_API_KEY'], params['token'], params['timestamp'], params['signature'])
      if params[:event] = "delivered"
        user = User.where(email: params[:recipient]).first
        user.touch(:last_email_sent) if user
      end
    end
    return head(200)
  end

  protected

  def mailgun?(api_key, token, timestamp, signature)
    encrypted = encrypt_signature(api_key, timestamp, token)
    return signature == encrypted
  end

  def encrypt_signature(api_key, timestamp, token)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), api_key, '%s%s' % [timestamp, token])
  end
end
