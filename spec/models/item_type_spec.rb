require 'rails_helper'

RSpec.describe ItemType, :type => :model do

  describe "validations" do

    it { should validate_presence_of(:name_en) }

  end

end
