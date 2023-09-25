class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy
  has_one_attached :profile_pic

  has_many :likes, dependent: :destroy

  has_many :comments, dependent: :destroy

  has_many :follow_requests, -> { where(accepted: false) }, class_name: "Follow", foreign_key: "followed_id"

  has_many :accepted_received_requests, -> { where(accepted: true) }, class_name: "Follow", foreign_key: "followed_id"

  has_many :accepted_sent_requests, -> { where(accepted: true) }, class_name: "Follow", foreign_key: "follower_id"

  # has_many :received_requests, class_name: "Follow", foreign_key: "followed_id"
  # has_many :sent_requests, class_name: "Follow", foreign_key: "follower_id"
  has_many :waiting_sent_requests, -> { where(accepted: false) }, class_name: "Follow", foreign_key: "follower_id"

  has_many :followers, through: :accepted_received_requests, source: :follower
  has_many :followings, through: :accepted_sent_requests, source: :followed
  has_many :waiting_followings, through: :waiting_sent_requests, source: :followed

  def follow(user)
    Follow.create(follower: self, followed: user)
  end

  def unfollow(user)
    self.accepted_sent_requests.find_by(followed: user)&.destroy
  end

  def cancel_request(user)
    self.waiting_sent_requests.find_by(followed: user)&.destroy
  end
end