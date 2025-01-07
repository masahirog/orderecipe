class Group < ApplicationRecord
    has_many :staffs, dependent: :destroy
    has_many :stores, dependent: :destroy
    has_many :shift_frames, dependent: :destroy
    has_many :fix_shift_patterns, dependent: :destroy
    has_many :tasks, dependent: :destroy
    has_many :materials, dependent: :destroy
    has_many :menus, dependent: :destroy
    has_many :products, dependent: :destroy
    has_many :vendors, dependent: :destroy
    has_many :users, dependent: :destroy
    has_many :brands, dependent: :destroy
end
