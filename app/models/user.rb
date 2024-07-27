class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true
  validates :password,
            length: { minimum: 5 },
            if: -> { new_record? || !password.nil? }
  validate :username_must_not_contain_email_patterns

  def username_must_not_contain_email_patterns
    if username =~ /\.(com|org|net|gov|edu|co\.in|in|us|uk|biz|info|name|me|io|ai|app|dev)$/
      errors.add(:username, "must not contain domains like .com, .co.in, etc.")
    end
  end
end