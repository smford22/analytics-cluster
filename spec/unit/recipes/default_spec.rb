require 'spec_helper'

describe "analytics-cluster::default" do
  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(
      platform: 'redhat',
      version: '6.3',
      log_level: :error
    )
    runner.converge('recipe[analytics-cluster::default]')
  end

  # TODO: Write some tests
end
