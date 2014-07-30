require 'spec_helper'

shared_context 'defaults' do |package_name|
  let(:pre_condition) { 'include mongodb::client' }
  include_context 'without_managed_repo'

  it {
    should contain_package(package_name).with({
      :ensure   => 'present',
    }).without_require
  }

end

shared_context 'with_custom_params' do
  let(:pre_condition) { [
    "class mongodb::client { $ensure = true $package_name = 'custom_package_name' }",
    "include mongodb::client"
  ]}

  it {
    should contain_package('custom_package_name').with({
      :ensure   => 'present',
    }).without_require
  }
end

shared_context 'with_managed_repo' do
  let(:pre_condition) { [
    "class mongodb::globals { $manage_package_repo = true }",
    "include mongodb::globals",
    "include mongodb::client"
  ]}
  it { should contain_class('mongodb::repo') }
end

shared_context 'with_managed_repo_with_version' do |package_name|
  let(:pre_condition) { [
    "class mongodb::globals { $manage_package_repo = true $version = '1.2.3.4' }",
    "include mongodb::globals",
    "include mongodb::client",
  ]}

  it { should contain_class('mongodb::repo') }

  it {
    should contain_package(package_name).with({
      :ensure   => '1.2.3.4',
      :require  => "Anchor[mongodb::repo::end]",
    })
  }
end

shared_context 'with_unmanaged_repo_with_version' do |package_name|
  let(:pre_condition) { [
    "class mongodb::globals { $version = '1.2.3.4' }",
    "include mongodb::globals",
    "include mongodb::client"
  ]}

  include_context 'without_managed_repo'

  it {
    should contain_package(package_name).with({
      :ensure   => '1.2.3.4',
    }).without_require
  }
end

shared_context 'without_managed_repo' do
  it { should_not contain_class('mongodb::repo') }
end


describe 'mongodb::client::install', :type => :class do
  describe 'it should create package' do

    context 'when deploying on RedHat' do
      let (:facts) { { :osfamily => 'RedHat' } }

      context 'using defaults' do
        include_context 'defaults', 'mongodb'
      end

      context 'using custom params' do
        include_context 'with_custom_params'
        include_context 'without_managed_repo'
      end

      context 'using managed repo' do
        include_context 'with_managed_repo'
      end

      context 'using version' do
        context 'using managed repo' do
          include_context 'with_managed_repo_with_version', 'mongodb-org-shell'
        end

        context 'using unmanaged repo' do
          include_context 'with_unmanaged_repo_with_version', 'mongodb'
        end
      end


    end

    context 'when deploying on Debian' do
      let (:facts) { {
        :osfamily   => 'Debian',
        :lsbdistid  => 'Debian' # rquired for apt
      } }

      context 'using defaults' do
        include_context 'defaults', 'mongodb-server'
      end

      context 'using custom params' do
        include_context 'with_custom_params'
        include_context 'without_managed_repo'
      end

      context 'using managed repo' do
        include_context 'with_managed_repo'
      end

      context 'using version' do
        context 'using managed repo' do
          include_context 'with_managed_repo_with_version', 'mongodb-org-shell'
        end

        context 'using unmanaged repo' do
          include_context 'with_unmanaged_repo_with_version', 'mongodb-server'
        end
      end

    end

  end
end
