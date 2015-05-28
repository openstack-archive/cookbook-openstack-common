# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-common::logging' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    describe '/etc/openstack' do
      let(:dir) { chef_run.directory('/etc/openstack') }

      it 'should create /etc/openstack' do
        expect(chef_run).to create_directory('/etc/openstack').with(
          owner: 'root',
          group: 'root',
          mode: 00755
        )
      end
    end

    describe 'logging.conf' do
      let(:file) { chef_run.template('/etc/openstack/logging.conf') }

      it 'should create /etc/openstack/logging.conf' do
        expect(chef_run).to create_template(file.name).with(
          owner: 'root',
          group: 'root',
          mode: 00644
        )
      end

      context 'loggers' do
        it 'adds default loggers' do
          {
            'loggers' =>
              [
                'keys=root,ceilometer,cinder,glance,horizon,keystone,nova,'\
                'neutron,trove,amqplib,sqlalchemy,boto,suds,eventletwsgi,'\
                'nova_api_openstack_wsgi,nova_osapi_compute_wsgi_server'
              ],
            'logger_root' =>
              [
                'level=NOTSET',
                'handlers=devel'
              ],
            'logger_ceilometer' =>
              [
                'level=DEBUG',
                'handlers=prod,debug',
                'qualname=ceilometer'
              ],
            'logger_cinder' =>
              [
                'level=DEBUG',
                'handlers=prod,debug',
                'qualname=cinder'
              ],
            'logger_glance' =>
              [
                'level=DEBUG',
                'handlers=prod,debug',
                'qualname=glance'
              ],
            'logger_horizon' =>
              [
                'level=DEBUG',
                'handlers=prod,debug',
                'qualname=horizon'
              ],
            'logger_keystone' =>
              [
                'level=DEBUG',
                'handlers=prod,debug',
                'qualname=keystone'
              ],
            'logger_nova' =>
              [
                'level=DEBUG',
                'handlers=prod,debug',
                'qualname=nova'
              ],
            'logger_neutron' =>
              [
                'level=DEBUG',
                'handlers=prod,debug',
                'qualname=neutron'
              ],
            'logger_trove' =>
              [
                'level=DEBUG',
                'handlers=prod,debug',
                'qualname=trove'
              ],
            'logger_amqplib' =>
              [
                'level=WARNING',
                'handlers=stderr',
                'qualname=amqplib'
              ],
            'logger_sqlalchemy' =>
              [
                'level=WARNING',
                'handlers=stderr',
                'qualname=sqlalchemy'
              ],
            'logger_boto' =>
              [
                'level=WARNING',
                'handlers=stderr',
                'qualname=boto'
              ],
            'logger_suds' =>
              [
                'level=INFO',
                'handlers=stderr',
                'qualname=suds'
              ],
            'logger_eventletwsgi' =>
              [
                'level=WARNING',
                'handlers=stderr',
                'qualname=eventlet.wsgi.server'
              ],
            'logger_nova_api_openstack_wsgi' =>
              [
                'level=WARNING',
                'handlers=prod,debug',
                'qualname=nova.api.openstack.wsgi'
              ],
            'logger_nova_osapi_compute_wsgi_server' =>
              [
                'level=WARNING',
                'handlers=prod,debug',
                'qualname=nova.osapi_compute.wsgi.server'
              ]
          }.each do |section, content|
            content.each do |line|
              expect(chef_run).to render_config_file(file.name).with_section_content(section, line)
            end
          end
        end
      end

      context 'formatters' do
        it 'adds default formatters' do
          {
            'formatters' =>
              'keys=normal,normal_with_name,debug,syslog_with_name,syslog_debug',
            'formatter_normal' =>
              'format=%(asctime)s %(levelname)s %(message)s',
            'formatter_normal_with_name' =>
              'format=[%(name)s]: %(asctime)s %(levelname)s %(message)s',
            'formatter_debug' =>
              'format=[%(name)s]: %(asctime)s %(levelname)s %(module)s.%(funcName)s %(message)s',
            'formatter_syslog_with_name' =>
              'format=%(name)s: %(levelname)s %(message)s',
            'formatter_syslog_debug' =>
              'format=%(name)s: %(levelname)s %(module)s.%(funcName)s %(message)s'
          }.each do |section, content|
            expect(chef_run).to render_config_file(file.name).with_section_content(section, content)
          end
        end
      end

      context 'handlers' do
        it 'adds default handlers' do
          {
            'handlers' =>
              ['keys=stderr,devel,prod,debug'],
            'handler_stderr' =>
              [
                'args=(sys.stderr,)',
                'class=StreamHandler',
                'formatter=debug'
              ],
            'handler_devel' =>
              [
                'args=(sys.stdout,)',
                'class=StreamHandler',
                'formatter=debug',
                'level=NOTSET'
              ],
            'handler_prod' =>
              [
                "args=(('/dev/log'), handlers.SysLogHandler.LOG_LOCAL0)",
                'class=handlers.SysLogHandler',
                'formatter=syslog_with_name',
                'level=INFO'
              ],
            'handler_debug' =>
              [
                "args=(('/dev/log'), handlers.SysLogHandler.LOG_LOCAL1)",
                'class=handlers.SysLogHandler',
                'formatter=syslog_debug',
                'level=DEBUG'
              ]
          }.each do |section, content|
            content.each do |line|
              expect(chef_run).to render_config_file(file.name).with_section_content(section, line)
            end
          end
        end
      end
    end
  end
end
