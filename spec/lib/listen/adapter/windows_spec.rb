RSpec.describe SassListen::Adapter::Windows do
  describe 'class' do
    subject { described_class }

    if windows?
      it { should be_usable }
    else
      it { should_not be_usable }
    end
  end
end
