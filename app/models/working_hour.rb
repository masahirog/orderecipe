require 'csv'
class WorkingHour < ApplicationRecord
  belongs_to :staff
  belongs_to :store
  has_many :working_hour_work_types

  attr_accessor :position
end
