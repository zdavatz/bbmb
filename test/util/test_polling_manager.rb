#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('..', File.dirname(__FILE__))

require 'test_helper'
require 'fileutils'
require 'bbmb/util/polling_manager'

module BBMB
  module Util
    # add an empty Transaction class for test only used in sandoz.xmlconv
    class Transaction
    end

    TestData = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test', 'examples'))
    class TestFileMission < Minitest::Test
      def setup
        super
        @datadir = File.expand_path('../data', File.dirname(__FILE__))
        BBMB.config = flexmock('config')
        BBMB.config.should_receive(:bbmb_dir).and_return(@datadir)
        @mission = FileMission.new
        @dir = File.expand_path('../data/poll', File.dirname(__FILE__))
        def @mission.filtered_transaction(src, origin, &block)
          block.call(Transaction.new)
        end
        FileUtils.mkdir_p(@dir)
        @mission.directory = @dir
      end
      def teardown
        BBMB.config = $default_config.clone
        super
      end
      def test_poll
        path = File.join(@dir, 'test.csv')
        File.open(path, 'w') { |fh| fh.puts 'data' }
        @mission.poll { |name, io|
          assert_equal('test.csv', name)
          assert_equal("data\n", io.read)
        }
        assert_equal(true, File.exist?(path))

        @mission.glob_pattern = '*.xls'
        @mission.poll { |name, io|
          flunk "glob_pattern *.xls should not match any files, matched #{name}"
        }

        @mission.glob_pattern = '*.csv'
        @mission.poll { |name, io|
          assert_equal('test.csv', name)
          assert_equal("data\n", io.read)
        }
      end
      def test_poll_path
        path = File.join(@dir, 'test.csv')
        File.open(path, 'w') { |fh| fh.puts 'data' }
        @mission.poll_path(path) { |name, io|
          assert_equal('test.csv', name)
          assert_equal("data\n", io.read)
        }
        assert_equal(true, File.exist?(path))
      end
      def test_poll_path__delete
        path = File.join(@dir, 'test.csv')
        File.open(path, 'w') { |fh| fh.puts 'data' }
        @mission.delete = true
        @mission.poll_path(path) { |name, io|
          assert_equal('test.csv', name)
          assert_equal("data\n", io.read)
        }
        assert_equal(false, File.exist?(path))
      end
      def test_poll_path__backup
        path = File.join(@dir, 'test.csv')
        File.open(path, 'w') { |fh| fh.puts 'data' }
        bdir = @mission.backup_dir = File.expand_path('../backup', @dir)
        bpath = File.join(bdir, 'test.csv')
        @mission.poll_path(path) { |name, io|
          assert_equal('test.csv', name)
          assert_equal("data\n", io.read)
        }
        assert_equal(true, File.exist?(path))
        assert_equal(true, File.exist?(bpath))
        assert_equal("data\n", File.read(bpath))
      end
      def test_poll_path__backup__error
        path = File.join(@dir, 'test.csv')
        File.open(path, 'w') { |fh| fh.puts 'data' }
        bdir = @mission.backup_dir = File.expand_path('../backup', @dir)
        bpath = File.join(bdir, 'test.csv')
        flexstub(BBMB::Util::Mail).should_receive(:notify_error).times(1)
        @mission.poll_path(path) { |name, io|
          assert_equal('test.csv', name)
          assert_equal("data\n", io.read)
          raise "some error"
        }
        assert_equal(true, File.exist?(path))
        assert_equal(true, File.exist?(bpath))
        assert_equal("data\n", File.read(bpath))
      end
    end
    class TestFtpMission < Minitest::Test
      def setup
        @datadir = File.expand_path('../data', File.dirname(__FILE__))
        BBMB.config = flexmock('config')
        BBMB.config.should_receive(:bbmb_dir).and_return(@datadir)
        @mission = FtpMission.new
        @mission.directory = "ftp://user:pass@ftp.server.com/path/to/dir"
      end
      def teardown
        BBMB.config = $default_config.clone
        super
      end
      def test_poll
        session = flexmock 'ftp'
        session.should_receive(:login).with('user', 'pass').times(2)
        session.should_receive(:chdir).with('path/to/dir').times(2)
        session.should_receive(:nlst).and_return %w{test.csv test.txt}
        session.should_receive(:get).and_return { |remote, local|
          assert_equal('test.txt', remote)
          File.open(local, 'w') { |fh| fh.puts "data" }
        }
        flexmock(Net::FTP).should_receive(:open).and_return { |host, block|
          assert_equal('ftp.server.com', host)
          block.call session
        }
        @mission.pattern = '.*\.txt'
        @mission.poll { |name, io|
          assert_equal('test.txt', name)
          assert_equal("data\n", io.read)
        }

        @mission.pattern = '.*\.xls'
        @mission.poll { |name, io|
          flunk "pattern .*\.xls should not match any files, matched #{name}"
        }
      end
      def test_poll_remote
        @mission.backup_dir = '/backup/dir'
        session = flexmock 'ftp'
        session.should_receive(:get).and_return { |remote, local|
          assert_equal('test.txt', remote)
          assert_equal('/backup/dir/test.txt', local)
        }
        assert_equal('/backup/dir/test.txt',
                     @mission.poll_remote(session, 'test.txt'))
      end
      def test_poll_remote__delete
        @mission.backup_dir = '/backup/dir'
        @mission.delete = true
        session = flexmock 'ftp'
        session.should_receive(:get).and_return { |remote, local|
          assert_equal('test.txt', remote)
          assert_equal('/backup/dir/test.txt', local)
        }
        session.should_receive(:delete).with('test.txt').times(1)
        assert_equal('/backup/dir/test.txt',
                     @mission.poll_remote(session, 'test.txt'))
      end
    end
    class TestPopMission < Minitest::Test
      def setup
        super
        @mission = PopMission.new
        @mission.host = "mail.ywesee.com"
        @mission.user = "data@bbmb.ch"
        @mission.pass = "test"
        @message = ::Mail.new do
          from    'customer@info.org'
          to      'orders@bbmb.org'
          subject 'This is a test email'
          add_part ::Mail::Part.new do
            body 'This is plain text'
          end
        end
        ::Mail.defaults do delivery_method :test end
        ::Mail::TestMailer.deliveries.clear
      end
      def teardown
        BBMB.config = $default_config.clone
        super
      end
      def test_poll_message__normal
        blk_called = false
        @message.add_file :filename => 'ywsarti.csv', :content_type => 'text/plain', :content => 'attached data'
        @mission.poll_message(@message) { |filename, data|
          assert_equal('ywsarti.csv', filename)
          assert_equal('attached data', data)
          blk_called = true
        }
        assert(blk_called, "poll_message never called its block")
      end
      def test_poll_message__many_parameters
        @message.add_file :filename => 'ywsarti.csv', :content_type => 'text/plain', :content => 'attached data'
        @message.parts[1].headers['foo'] = 'b.r'
        blk_called = false
        @mission.poll_message(@message) { |filename, data|
          assert_equal('ywsarti.csv', filename)
          assert_equal('attached data', data)
          blk_called = true
        }
        assert(blk_called, "poll_message never called its block")
      end
      def test_poll_message__no_quotes
        @message.add_file :filename => 'ywsarti', :content_type => 'text/plain', :content => 'attached data'
        @message.parts[1].headers['foo'] = 'bar'
        blk_called = false
        @mission.poll_message(@message) { |filename, data|
          assert_equal('ywsarti', filename)
          assert_equal('attached data', data)
          blk_called = true
        }
        assert(blk_called, "poll_message never called its block")
      end
      def test_poll
        @message.add_file :filename => 'ywsarti.csv', :content_type => 'text/plain', :content => 'attached data'
        @message.deliver
        assert_equal(1, ::Mail::TestMailer.deliveries.length)
        def @mission.filtered_transaction(src, origin, &block)
          block.call(Transaction.new)
        end
        @mission.poll { |name, data|
          assert_equal('ywsarti.csv', name)
          assert_equal('attached data', data)
        }
      end
    end
    class TestPopMissionXmlConv < ::Minitest::Test
      def setup
        super
        @popserver = TCPServer.new('127.0.0.1', 0)
        addr = @popserver.addr
        @mission = PopMission.new
        @mission.host = 'localhost'
        @mission.port = addr.at(1)
        @mission.user = "testuser"
        @mission.pass = "test"
        @mission.content_type = "text/xml"
        @datadir = File.expand_path('data', File.dirname(__FILE__))
        ::Mail.defaults do delivery_method :test end
        ::Mail::TestMailer.deliveries.clear
      end
      def teardown
        BBMB.config = $default_config.clone
        FileUtils.rm_r(@datadir)
        super
      end
      def test_poll
        mail = ::Mail.read(File.join(TestData, 'simple_email.txt'))
        mail.deliver
        mail = ::Mail.read(File.join(TestData, 'sandoz.xundart@bbmb.ch.20110524001038.928592'))
        mail.deliver
        nr_messages = 2
        assert_equal(nr_messages, ::Mail::TestMailer.deliveries.length)
        counter = 0
        def @mission.filtered_transaction(src, origin, &block)
          block.call(Transaction.new)
        end
        def @mission.filtered_transaction(src, origin, &block)
          block.call(Transaction.new)
        end
        @mission.poll do |transaction|
          counter += 1
          assert_instance_of(Util::Transaction, transaction)
        end
        assert_equal(nr_messages, counter,  "poll-block should have been called exactly #{nr_messages} times")
      end
      def teardown
        @popserver.close
        super
      end
    end
    class TestPollingManager < Minitest::Test
      def setup
        super
        BBMB.config = $default_config.clone
        @manager = PollingManager.new
        @datadir = File.expand_path('data', File.dirname(__FILE__))
      end
      def teardown
        BBMB.config = $default_config.clone
        super
      end
      def test_load_sources
        FileUtils.mkdir_p(@datadir)
        path = File.join(@datadir, 'polling.yml')
        mission = PopMission.new
        mission.host = "mail.ywesee.com"
        mission.user = "data@bbmb.ch"
        mission.pass = "test"
        File.open(path, 'w') { |fh| fh.puts mission.to_yaml }
        config = flexmock("config")
        config.should_receive(:polling_file).and_return(path)
        BBMB.config = config
        @manager.load_sources { |mission|
          assert_equal("mail.ywesee.com", mission.host)
          assert_equal("data@bbmb.ch", mission.user)
          assert_equal("test", mission.pass)
        }
      ensure
        FileUtils.rm_r(@datadir) if(File.exist?(@datadir))
      end
      def test_poll_sources
        flexstub(@manager).should_receive(:load_sources).and_return { |block|
          source = flexmock("source")
          source.should_receive(:poll)
          block.call(source)
          assert(true)
        }
        @manager.poll_sources
      end
    end
  end
end
