class Micropost < ApplicationRecord

  # Dependencies

  belongs_to :user

  # Validators

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  # Modifications

  default_scope -> { order(created_at: :desc) }


end
