require 'spec_helper'

describe Puppet::Face[:node_gce, :current] do
  before do
    @handle = Puppet::GoogleCompute.new
    Puppet::GoogleCompute.stubs(:new).returns(@handle)
  end

  it 'supports creating an instance' do
    lambda { subject.create }.should_not raise_error
  end

  describe 'when listing instance data' do
    let :options do
      { :project => 'megaproject' }
    end

    it 'requires a project name' do
      lambda {
        options.delete[:project]
        subject.list(options)
      }.should raise_error(ArgumentError)
    end

    describe 'and a project name is available' do
      it 'requests running instance list data for the given project via the Google Compute REST API' do
        @handle.expects(:instance_list).with(options[:project])
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
      {
        :project => 'megaproject'
      }
    end

    it 'requires a project name' do
      lambda {
        options.delete[:project]
        subject.project(options)
      }.should raise_error(ArgumentError)
    end

    describe 'and a project name is available' do
      it 'requests project data for the given project via the Google Compute REST API' do
        @handle.expects(:get_project).with(options[:project])
        subject.project(options)
      end

      it 'returns the project data provided by the Google Compute REST API' do
        @handle.stubs(:get_project).returns( {:foo => 'bar'} )
        subject.project(options).should == {:foo => 'bar'}
      end

      it 'outputs the project data provided by the Google Compute REST API to the console' do
        pending("figuring out how to test the console output hook")
      end
    end
  end
end