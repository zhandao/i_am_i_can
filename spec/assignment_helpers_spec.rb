RSpec.describe IAmICan::Dynamic do
  let(:people) { User }
  let(:people) { User }
  subject { User.create }
  let(:he) { subject }
  let(:his) { subject }
  let(:roles) { UserRole }

  cls_cleaning

  before do
    people.have_role :admin, :master, :guest, :dev
  end

  describe '#_stored_roles_add' do
    context 'when passing an condition' do
      before { he._stored_roles_add(name: :guest) }

      it { expect(he._stored_roles_add(name: [:admin, :dev])).to eq(roles.where(name: [:admin, :dev])) }
    end

    context 'when passing instances' do
      before { he._stored_roles_add(name: :guest) }

      it { expect(he._stored_roles_add(roles.all)).to eq(roles.where(name: [:admin, :master, :dev])) }
    end

    context 'when passing both' do
      before { he._stored_roles_add(name: :guest) }

      it { expect(he._stored_roles_add([roles.which(name: :dev)], { name: :admin })).to eq(roles.where(name: [:admin, :dev])) }
    end
  end
end
