require 'spec_helper'

describe Puppet::Face[:node_gce, :current] do
  let :options do
    { :project => 'megaproject', :name => 'foonode' }
  end

  before do
    @handle = Puppet::GoogleCompute.new(options[:project])
    Puppet::GoogleCompute.stubs(:new).returns(@handle)

    # neuter live API requests
    @handle.stubs(:get).returns('')
    @handle.stubs(:post).returns('')
  end

  describe 'when creating an instance' do
    it 'requires a project name' do
      lambda {
        options.delete(:project)
        subject.create(options)
      }.should raise_error(ArgumentError)
    end

    it 'requires a node name' do
      lambda {
        options.delete(:name)
        subject.create(options)
      }.should raise_error(ArgumentError)
    end

    describe 'and a project name is available' do
      it 'provides the project name to the Google Compute REST API' do
        Puppet::GoogleCompute.expects(:new).with(options[:project]).returns(@handle)
        subject.create(options)
      end

      it 'requests running instance list data for the given project via the Google Compute REST API' do
        @handle.expects(:instance_create).with(options)
        subject.create(options)
      end

      it 'returns the running instance list data provided by the Google Compute REST API' do
        @handle.stubs(:instance_create).returns( {:foo => 'bar'} )
        subject.create(options).should == {:foo => 'bar'}
      end

      it 'outputs the running instance list data provided by the Google Compute REST API to the console' do
        pending("figuring out how to test the console output hook")
      end
    end
  end

  describe 'when listing instance data' do
    it 'requires a project name' do
      lambda {
        options.delete(:project)
        subject.list(options)
      }.should raise_error(ArgumentError)
    end

    describe 'and a project name is available' do
      it 'provides the project name to the Google Compute REST API' do
        Puppet::GoogleCompute.expects(:new).with(options[:project]).returns(@handle)
        subject.list(options)
      end

      it 'requests running instance list data for the given project via the Google Compute REST API' do
        @handle.expects(:instance_list).with()
        subject.list(options)
      end

      it 'returns the running instance list data provided by the Google Compute REST API' do
        @handle.stubs(:instance_list).returns( {:foo => 'bar'} )
        subject.list(options).should == {:foo => 'bar'}
      end

      it 'outputs the running instance list data provided by the Google Compute REST API to the console' do
        pending("figuring out how to test the console output hook")
      end
    end
  end

  describe 'when retrieving project data' do
    let :options do
      { :project => 'megaproject' }
    end

    it 'requires a project name' do
      lambda {
        options.delete(:project)
        subject.project(options)
      }.should raise_error(ArgumentError)
    end

    describe 'and a project name is available' do
      it 'provides the project name to the Google Compute REST API' do
        Puppet::GoogleCompute.expects(:new).with(options[:project]).returns(@handle)
        subject.project(options)
      end

      it 'requests project data for the given project via the Google Compute REST API' do
        @handle.expects(:project_get).with()
        subject.project(options)
      end

      it 'returns the project data provided by the Google Compute REST API' do
        @handle.stubs(:project_get).returns( {:foo => 'bar'} )
        subject.project(options).should == {:foo => 'bar'}
      end

      it 'outputs the project data provided by the Google Compute REST API to the console' do
        pending("figuring out how to test the console output hook")
      end
    end
  end
end