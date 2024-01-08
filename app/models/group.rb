class Group < ApplicationRecord
    has_many :staffs
    has_many :stores
    has_many :shift_frames
    has_many :fix_shift_patterns
    has_many :tasks
    has_many :materials
    has_many :menus
    has_many :products
    has_many :vendors
    has_many :users
end
