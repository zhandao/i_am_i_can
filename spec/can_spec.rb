RSpec.describe IAmICan::Can do
  let(:people) { User }
  let(:people) { User }
  subject { User.create }
  let(:he) { subject }
  let(:his) { subject }

  before do
    people.have_role :admin, :master, :guest, :dev
    UserRole.has_permission :fly
    UserRole.which(name: :admin).can :fly
    he.becomes_a :admin
  end

  describe '#can?' do
    it { expect(he.can? :fly).to be_truthy }
  end
end
