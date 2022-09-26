require 'spec_helper'

describe 'rsyslog::default' do
  platform 'ubuntu'

  let(:service_resource) { 'service[rsyslog]' }

  it do
    is_expected.to install_package('rsyslog')
  end

  context "when node['rsyslog']['relp'] is true" do
    default_attributes['rsyslog']['use_relp'] = true

    it do
      is_expected.to install_package('rsyslog-relp')
    end
  end

  context "when node['rsyslog']['max_message_size'] is nil" do
    default_attributes['rsyslog']['max_message_size'] = nil

    it do
      is_expected.to_not render_file('/etc/rsyslog.conf').with_content(/\$MaxMessageSize \s+/mix)
    end
  end

  context "when node['rsyslog']['enable_tls'] is true" do
    default_attributes['rsyslog']['enable_tls'] = true

    context "when node['rsyslog']['tls_ca_file'] is not set" do
      it do
        is_expected.not_to install_package('rsyslog-gnutls')
      end
    end

    context "when node['rsyslog']['tls_ca_file'] is set" do
      default_attributes['rsyslog']['tls_ca_file'] = '/etc/path/to/ssl-ca.crt'

      it do
        is_expected.to install_package('rsyslog-openssl')
      end

      context "when protocol is not 'tcp'" do
        default_attributes['rsyslog']['tls_ca_file'] = '/etc/path/to/ssl-ca.crt'
        default_attributes['rsyslog']['protocol'] = 'udp'

        it do
          expect { chef_run }.to raise_error(RuntimeError)
        end
      end
    end
  end

  it do
    is_expected.to create_directory('/etc/rsyslog.d').with(
      owner: 'root',
      group: 'root',
      mode: '0755'
    )
  end

  it do
    is_expected.to create_directory('/var/spool/rsyslog').with(
      owner: 'syslog',
      group: 'adm',
      mode: '0700'
    )
  end

  it do
    is_expected.to create_template('/etc/rsyslog.conf').with(
      owner: 'root',
      group: 'root',
      mode: '0644'
    )
  end

  it do
    is_expected.to render_file('/etc/rsyslog.conf').with_content('Config generated by Chef - manual edits will be overwritten')
    %w(imuxsock imklog).each do |mod|
      is_expected.to render_file('/etc/rsyslog.conf').with_content(/^\$ModLoad #{mod}/)
    end
  end

  it do
    expect(chef_run.template('/etc/rsyslog.conf')).to notify('service[rsyslog]').to(:restart)
  end

  it do
    is_expected.to create_template('/etc/rsyslog.d/50-default.conf').with(
      owner: 'root',
      group: 'root',
      mode: '0644'
    )
  end

  it do
    is_expected.to render_file('/etc/rsyslog.d/50-default.conf').with_content('*.emerg    :omusrmsg:*')
  end

  it do
    is_expected.to start_service('rsyslog')
  end

  context 'COOK-3608 maillog regression test' do
    platform 'centos'

    it do
      is_expected.to render_file('/etc/rsyslog.d/50-default.conf').with_content('mail.*    -/var/log/maillog')
    end
  end

  context 'when /etc/rsyslog.d/35-imfile.conf is created' do
    let(:template) { chef_run.template('/etc/rsyslog.d/35-imfile.conf') }
    before do
      template.run_action(:create)
    end

    context 'when on centos' do
      platform 'centos'

      default_attributes['rsyslog']['imfile']['PollingInterval'] = 10

      it do
        is_expected.to create_template('/etc/rsyslog.d/35-imfile.conf').with(
          owner: 'root',
          group: 'root',
          mode: '0644'
        )
      end

      it do
        expect(chef_run.template('/etc/rsyslog.d/35-imfile.conf')).to notify('service[rsyslog]').to(:restart)
      end

      it do
        is_expected.to_not render_file('/etc/rsyslog.d/35-imfile.conf').with_content('$ModLoad imfile')
      end

      it do
        is_expected.to render_file('/etc/rsyslog.d/35-imfile.conf').with_content('PollingInterval')
      end
    end

    context 'when on ubuntu' do
      platform 'ubuntu'

      default_attributes['rsyslog']['imfile']['PollingInterval'] = 10

      it "node['rsyslog']['config_style'] will be nil by default" do
        expect(chef_run.node['rsyslog']['config_style']).to eq(nil)
      end

      it do
        is_expected.to create_template('/etc/rsyslog.d/35-imfile.conf').with(
          owner: 'root',
          group: 'root',
          mode: '0644'
        )
      end

      it do
        expect(chef_run.template('/etc/rsyslog.d/35-imfile.conf')).to notify('service[rsyslog]').to(:restart)
      end

      it do
        is_expected.to_not render_file('/etc/rsyslog.d/35-imfile.conf').with_content('$ModLoad imfile')
      end

      it do
        is_expected.to render_file('/etc/rsyslog.d/35-imfile.conf').with_content(/module\(load="imfile"/)
      end

      it do
        is_expected.to render_file('/etc/rsyslog.d/35-imfile.conf').with_content(/PollingInterval="10"/)
      end
    end
  end
end
