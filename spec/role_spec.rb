RSpec.describe IAmICan::Am do
  subject { User }
  let(:they) { subject }
  let(:their) { subject }

  describe '#has_role' do
    before { they.has_role :admin }
    it { expect(:admin).to be_in(they.roles.keys) }
  end

  describe '#group_roles' do
    context 'when passed block' do
      before do
        they.group_roles by_name: :vip do
          #
        end
      end
    end
  end
end
