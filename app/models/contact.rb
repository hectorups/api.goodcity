class Contact < ActiveRecord::Base
  has_one :address, as: :addressable, dependent: :destroy
  has_one :delivery, dependent: :destroy
end
