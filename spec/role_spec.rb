RSpec.describe IAmICan::Role do
  subject { User.new }

  describe '#is' do
    it do
      subject.is :admin
      expect(subject.roles_list).to include(admin: true)
    end
  end
end
