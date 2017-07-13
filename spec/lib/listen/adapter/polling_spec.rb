include SassListen

RSpec.describe Adapter::Polling do
  describe 'class' do
    subject { described_class }
    it { should be_usable }
  end

  subject do
    described_class.new(config)
  end

  let(:dir1) do
    instance_double(Pathname, 'dir1', to_s: '/foo/dir1', cleanpath: real_dir1)
  end

  # just so cleanpath works in above double
  let(:real_dir1) { instance_double(Pathname, 'dir1', to_s: '/foo/dir1') }

  let(:config) { instance_double(SassListen::Adapter::Config) }
  let(:directories) { [dir1] }
  let(:options) { {} }
  let(:queue) { instance_double(Queue) }
  let(:silencer) { instance_double(SassListen::Silencer) }
  let(:snapshot) { instance_double(SassListen::Change) }

  let(:record) { instance_double(SassListen::Record) }

  context 'with a valid configuration' do
    before do
      allow(config).to receive(:directories).and_return(directories)
      allow(config).to receive(:adapter_options).and_return(options)
      allow(config).to receive(:queue).and_return(queue)
      allow(config).to receive(:silencer).and_return(silencer)

      allow(SassListen::Record).to receive(:new).with(dir1).and_return(record)

      allow(SassListen::Change).to receive(:new).with(config, record).
        and_return(snapshot)
      allow(SassListen::Change::Config).to receive(:new).with(queue, silencer).
        and_return(config)
    end

    describe '#start' do
      before do
        allow(snapshot).to receive(:record).and_return(record)
        allow(record).to receive(:build)
      end

      it 'notifies change on every listener directories path' do
        expect(snapshot).to receive(:invalidate).
          with(:dir, '.', recursive: true)

        t = Thread.new { subject.start }
        sleep 0.25
        t.kill
        t.join
      end
    end

    describe '#_latency' do
      subject do
        adapter = described_class.new(config)
        adapter.options.latency
      end

      context 'with no overriding option' do
        it { should eq 1.0 }
      end

      context 'with custom latency overriding' do
        let(:options) { { latency: 1234 } }
        it { should eq 1234 }
      end
    end
  end
end
