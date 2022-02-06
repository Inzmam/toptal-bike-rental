class User < ApplicationRecord
  has_secure_password :validations => false

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  has_many :reservations, dependent: :destroy
end
