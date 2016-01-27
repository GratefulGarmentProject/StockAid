class Order < ActiveRecord::Base
  VALID_STATUSES = %i(pending approved rejected filled shipped received)
end
