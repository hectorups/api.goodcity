require 'rails_helper'

describe User, :type => :model do

  let(:mobile) { generate(:mobile) }
  let(:address_attributes) { { 'district_id' => "9", 'address_type' => "profile" } }
  let(:user_attributes) {  FactoryGirl.attributes_for(:user).merge('mobile' => mobile, 'address_attributes' => address_attributes).stringify_keys }

  let(:invalid_user_attributes) { { 'mobile' => "85211111112", 'first_name' => "John2", 'last_name' => "Dey2" } }

  let(:user) { create :user }

  describe 'Associations' do
    it { should have_many :auth_tokens }
    it { should have_many :offers }
    it { should have_many :messages }
    it { should have_many :sent_messages }
    it { should belong_to :permission }
    it { should have_one  :address }
  end

  describe 'Database columns' do
    it{ should  have_db_column(:first_name).of_type(:string)}
    it{ should  have_db_column(:last_name).of_type(:string)}
    it{ should  have_db_column(:mobile).of_type(:string)}
  end

  describe "Validations" do

    context "mobile" do
      it { should validate_presence_of(:mobile) }
      it { should validate_uniqueness_of(:mobile) }
      it { should allow_value('+85251234567').for(:mobile) }
      it { should allow_value('+85261234567').for(:mobile) }
      it { should allow_value('+85291234567').for(:mobile) }
      it { should_not allow_value('+85211234567').for(:mobile) }
      it { should_not allow_value('+44123456675').for(:mobile) }
      it { should_not allow_value('4412345').for(:mobile) }
      it { should_not allow_value('invalid').for(:mobile) }
    end

  end

  describe '.creation_with_auth' do

    context "when mobile does not exist" do
      let(:new_user) { build(:user) }
      it "should create new user" do
        allow(new_user).to receive(:send_verification_pin)
        expect(User).to receive(:new).with(user_attributes).and_return(new_user)
        User.creation_with_auth(user_attributes)
      end
    end

    context "when mobile does exist" do
      it "should send pin to existing user" do
        user = create(:user, mobile: mobile)
        expect(User).to receive(:find_by_mobile).with(mobile).and_return(user)
        expect(user).to receive(:send_verification_pin)
        User.creation_with_auth(user_attributes)
      end
    end

    context "when mobile blank" do
      let(:mobile) { nil }
      it "should raise validation error" do
        user = User.creation_with_auth(user_attributes)
        expect(user.errors[:mobile]).to include("can't be blank")
        expect(user.errors[:mobile]).to include("must begin with +852")
      end
    end

  end

  describe '#send_verification_pin' do

    let(:flowdock)   { EmailFlowdockService.new(user) }
    let(:twilio)     { TwilioService.new(user) }

    it "should send pin via Twilio" do
      expect(EmailFlowdockService).to receive(:new).with(user).and_return(flowdock)
      expect(flowdock).to receive(:send_otp)
      expect(TwilioService).to receive(:new).with(user).and_return(twilio)
      expect(twilio).to receive(:sms_verification_pin)
      user.send_verification_pin
    end

  end

  describe '#generate_auth_token' do
    it 'create an auth_token record, after user creation' do
      user = build(:user)
      expect(user.auth_tokens.size).to eq(0)
      user.save!
      expect(user.auth_tokens.size).to_not eq(0)
    end
  end

end
