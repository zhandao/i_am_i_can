RSpec.describe IAmICan::Permission::Definition do
  subject { UserRole }
  let(:roles) { subject }
  let(:role) { roles.create(name: :admin) }
  let(:permission_records) { UserPermission }
  let(:user) { User.create(id: 1) }

  cls_cleaning

  context '.has_permission' do
    before { roles.has_permission :manage, obj: User }
    it { expect(:manage_User).to be_in permission_records.all.map(&:name) }
    it { expect(permission_records.last).to have_attributes(action: 'manage', obj_type: 'User', obj_id: nil) }
    it { expect(permission_records.last.obj).to eq User }

    context 'when giving multi actions' do
      context 'without obj' do
        before { roles.has_permissions :fly, :run, :jump }
        it { expect(permission_records.all.map(&:name)).to contain(%i[fly run jump])}
        it { expect(permission_records.count).to eq(1+3) }
        it { expect(permission_records.last.obj).to eq nil }
      end

      context 'with obj' do
        before { roles.has_permissions *%i[read write copy remove], obj: user }
        it { expect(permission_records.all.map(&:name)).to contain(%i[read_User_1 write_User_1 copy_User_1 remove_User_1])}
        it { expect(permission_records.count).to eq(1+4) }
        it { expect(permission_records.last.obj).to eq user }
      end
    end
  end
end
