class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  # devise :omniauthable, omniauth_providers: %i[cognito-idp]

  has_many :event_rsvps
end
