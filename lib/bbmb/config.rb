#!/usr/bin/env ruby
# @config -- bbmb.ch -- 08.09.2006 -- hwyss@ywesee.com

require 'rclconf'
require 'bbmb'

module BBMB
  default_dir = if(root =  ENV['DOCUMENT_ROOT'])
                  File.expand_path('../etc', root)
                elsif(home = ENV['HOME'])
                  File.expand_path('.bbmb/etc', home)
                else
                  require 'tmpdir'
                  Dir.tmpdir
                end
  default_config_files = [
    File.join(default_dir, 'bbmb.yml'),
    '/etc/bbmb/bbmb.yml',
  ]
  defaults = {
    'admin_address'                   => '',
    'admins'                          => [],
    'auth_domain'                     => 'ch.bbmb',
    'auth_url'                        => 'druby://localhost:12001',
    'bbmb_dir'                        => File.expand_path('..', default_dir),
    'config'			                    => default_config_files,
    'confirm_error_body'              => 'Customer %s does not have an email address configured',
    'confirm_error_cc'                => [],
    'confirm_error_from'              => 'errors.test@bbmb.ch',
    'confirm_error_subject'           => 'Customer %s without email address',
    'confirm_error_to'                => nil,
    'data_dir'                        => File.expand_path('../data', default_dir),
    'db_name'                         => 'bbmb',
    'db_user'                         => 'bbmb',
    'db_auth'                         => 'bbmb',
    'db_backend'                      => :psql,
    'debug'                           => true,
    'enable_price_levels'             => false,
    'error_recipients'                => [],
    'http_server'                     => 'http://www.bbmb.ch',
    'importers'                       => {
       'ywsarti.csv'                  => 'ProductImporter',
       'ywskund.csv'                  => 'CustomerImporter',
    },
    'inject_error_body'               => 'The order %s, committed on %s, assigned to the unknown customer: %s',
    'inject_error_cc'                 => [],
    'inject_error_from'               => 'errors.test@bbmb.ch',
    'inject_error_subject'            => 'Order %s with missing customer: %s',
    'inject_error_to'                 => nil,
    'invoice?'                        => true,
    'invoice_baseline'                => nil,
    'invoice_monthly_baseline'        => nil,
    'invoice_monthly_baseamount'      => nil,
    'invoice_format'                  => "Invoice %s-%s",
    'invoice_item_format'             => "Turnover: %1.2f \nOrders: %i",
    'invoice_item_baseamount_format'  => "Turnover up to the base amount",
    'invoice_item_baseamount_unit'    => "Base-Amount",
    'invoice_newyear'                 => "1.1.",
    'invoice_percentage'              => 0.1,
    'i2_100'                          => 'YWESEE',
    'load_files'                      => ['bbmb/util/csv_importer'],
    'log_file'                        => STDERR,
    'log_level'                       => 'INFO',
    'mail_suppress_sending'           => false,
    'mail_confirm_body'               => nil,
    'mail_confirm_cc'                 => [],
    'mail_confirm_from'               => 'confirm.test@bbmb.ch',
    'mail_confirm_reply_to'           => nil, ## used for determining if a confirmation should be sent
    'mail_confirm_lines'              => [],
    'mail_confirm_subject'            => 'Bbmb-Confirm %s',
    'mail_order_cc'                   => [],
    'mail_order_from'                 => 'orders.test@bbmb.ch',
    'mail_order_subject'              => 'Bbmb-Order %s',
    'mail_order_to'                   => 'orders.test@bbmb.ch',
    'mail_request_cc'                 => [],
    'mail_request_from'               => 'requests.test@bbmb.ch',
    'mail_request_subject'            => 'Bbmb-Request %s',
    'mail_request_to'                 => 'requests.test@bbmb.ch',
    'name'                            => 'Bbmb(test)',
    'order_destinations'              => [],
    'pagestep'                        => 20,
    'persistence'                     => 'odba',
    'polling_file'                    => File.expand_path('polling.yml', default_dir),
    'scm_link'                        => 'http://scm.ywesee.com/?p=bbmb/.git',
    'server_url'                      => 'druby://localhost:12000',
    'session_timeout'                 => 3600,
    'smtp_authtype'                   => nil,
    'smtp_domain'                     => 'localdomain',
    'smtp_helo'                       => 'localhost.localdomain',
    'smtp_pass'                       => nil,
    'smtp_port'                       => 25,
    'smtp_server'                     => 'mail.bbmb.ch',
    'smtp_user'                       => nil,
    'target_format'                   => 'i2',
    'target_format_fs'                => ",",
    'target_format_rs'                => "\n",
    'tmpfile_basename'                => 'bbmb',
    'update?'                         => true,
    'update_hour'                     => 23,
    'vat_rate'                        => 2.4,
    'ydim_config'                     => nil,
    'ydim_id'                         => nil,
  }

  config = RCLConf::RCLConf.new(ARGV, defaults)
  config.load(config.config)
  @config = config
end
