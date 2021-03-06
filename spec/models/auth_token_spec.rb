require 'rails_helper'

describe AuthToken, :type => :model do

  describe 'Association' do
    it { should belong_to :user }
  end

  describe 'Database columns' do
    it{ should have_db_column(:otp_code_expiry).of_type(:datetime)}
    it{ should have_db_column(:otp_secret_key).of_type(:string)}
    it{ should have_db_column(:otp_auth_key).of_type(:string)}
    it{ should have_db_column(:user_id).of_type(:integer)}
  end

  context "create" do
    it { expect( AuthToken.create.otp_auth_key ).to_not be_nil }
    it { expect( AuthToken.create.otp_secret_key ).to_not be_nil }
  end

  context "validations" do
    it { expect(AuthToken.create).to validate_presence_of(:otp_auth_key) }
  end

end
