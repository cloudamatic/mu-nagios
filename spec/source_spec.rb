require 'spec_helper'

describe 'nagios::default' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04') do |node, server|
      node.normal['nagios']['server']['install_method'] = 'source'
      server.create_data_bag('users',
                                        'user1' => {
                                          'id' => 'tsmith',
                                          'groups' => ['sysadmin'],
                                          'nagios' => {
                                            'pager' => 'nagiosadmin_pager@example.com',
                                            'email' => 'nagiosadmin@example.com',
                                          },
                                        },
                                        'user2' => {
                                          'id' => 'bsmith',
                                          'groups' => ['users'],
                                        })
    end.converge(described_recipe)
  end

  before do
    stub_command('/usr/sbin/apache2 -t').and_return(true)
  end

  it 'should include the server_source recipe' do
    expect(chef_run).to include_recipe('mu-nagios::server_source')
  end

  it 'should include the php::default recipe' do
    expect(chef_run).to include_recipe('php::default')
  end

  it 'should install the php-gd package' do
    expect(chef_run).to install_package('php-gd')
  end

  it 'should include source install dependency packages' do
    expect(chef_run).to install_package('libssl-dev')
    expect(chef_run).to install_package('libgd2-xpm-dev')
    expect(chef_run).to install_package('bsd-mailx')
    expect(chef_run).to install_package('tar')
  end

  it 'should create nagios user and group' do
    expect(chef_run).to create_user('nagios')
    expect(chef_run).to create_group('nagios')
  end

  it 'should create nagios directories' do
    expect(chef_run).to create_directory('/etc/nagios3')
    expect(chef_run).to create_directory('/etc/nagios3/conf.d')
    expect(chef_run).to create_directory('/var/cache/nagios3')
    expect(chef_run).to create_directory('/var/log/nagios3')
    expect(chef_run).to create_directory('/var/lib/nagios3')
    expect(chef_run).to create_directory('/var/run/nagios3')
  end
end
