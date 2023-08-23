
class User < ApplicationRecord
  belongs_to :relationship, optional: true

end
