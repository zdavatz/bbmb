#!/usr/bin/env ruby
# Util::TestPollingManager -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'bbmb/util/polling_manager'
require 'fileutils'

module BBMB
  module Util
    class TestFileMission < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @datadir = File.expand_path('../data', File.dirname(__FILE__))
        BBMB.config = flexmock('config')
        BBMB.config.should_receive(:bbmb_dir).and_return(@datadir)
        @mission = FileMission.new
        @dir = File.expand_path('../data/poll', File.dirname(__FILE__))
        FileUtils.mkdir_p(@dir)
        @mission.directory = @dir
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
        assert_equal(false, File.exist?(path))
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
        assert_equal(false, File.exist?(path))
        assert_equal(true, File.exist?(bpath))
        assert_equal("data\n", File.read(bpath))
      end
    end
    class TestPopMission < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @mission = PopMission.new
        @mission.host = "mail.ywesee.com"
        @mission.user = "data@bbmb.ch"
        @mission.pass = "test"
      end
      def test_poll_message__normal
        message = RMail::Message.new
        part1 = RMail::Message.new
        part1.body = "inline text"
        message.add_part(part1)
        part2 = RMail::Message.new
        part2.body = "attached data"
        part2.header.add("Content-Type",'TEXT/plain', nil,
                         'NAME' => "=?ISO-8859-1?Q?ywsarti.csv?=")
        message.add_part(part2)
        blk_called = false
        @mission.poll_message(message) { |filename, data|
          assert_equal('ywsarti.csv', filename) 
          assert_equal('attached data', data) 
          blk_called = true
        }
        assert(blk_called, "poll_message never called its block")
      end
      def test_poll_message__many_parameters
        message = RMail::Message.new
        part1 = RMail::Message.new
        part1.body = "inline text"
        message.add_part(part1)
        part2 = RMail::Message.new
        part2.body = "attached data"
        part2.header.add("Content-Type",'TEXT/plain', nil,
                         [['NAME', "ywsarti.csv"], ["foo", "b.r"]])
        message.add_part(part2)
        blk_called = false
        @mission.poll_message(message) { |filename, data|
          assert_equal('ywsarti.csv', filename) 
          assert_equal('attached data', data) 
          blk_called = true
        }
        assert(blk_called, "poll_message never called its block")
      end
      def test_poll_message__no_quotes
        message = RMail::Message.new
        part1 = RMail::Message.new
        part1.body = "inline text"
        message.add_part(part1)
        part2 = RMail::Message.new
        part2.body = "attached data"
        part2.header.add("Content-Type",'text/plain', nil,
                         [['filename', "ywsarti"], ["foo", "bar"]])
        message.add_part(part2)
        blk_called = false
        @mission.poll_message(message) { |filename, data|
          assert_equal('ywsarti', filename) 
          assert_equal('attached data', data) 
          blk_called = true
        }
        assert(blk_called, "poll_message never called its block")
      end
      def test_poll
        src = <<-EOS
Content-Type: multipart/mixed; boundary="=-1158308026-727155-3822-1761-1-="
MIME-Version: 1.0


--=-1158308026-727155-3822-1761-1-=

inline text
--=-1158308026-727155-3822-1761-1-=
Content-Disposition: attachment; filename="ywsarti.csv"

attached data
--=-1158308026-727155-3822-1761-1-=--
        EOS
        flexstub(Net::POP3).should_receive(:start).with('mail.ywesee.com', 110, 
          'data@bbmb.ch', 
          'test', Proc).and_return { |host, port, user, pass, block|
          pop = flexmock('pop')
          pop.should_receive(:each_mail).and_return { |block2|
            mail = flexmock('mail')
            mail.should_receive(:pop).and_return(src)
            mail.should_receive(:delete)
            block2.call(mail)
          }
          block.call(pop)
        }
        @mission.poll { |name, data|
          assert_equal('ywsarti.csv', name)
          assert_equal('attached data', data)
        }
      end
      def test_poll__error
        src = <<-EOS
Content-Type: multipart/mixed; boundary="=-1158308026-727155-3822-1761-1-="
MIME-Version: 1.0


--=-1158308026-727155-3822-1761-1-=

inline text
--=-1158308026-727155-3822-1761-1-=
Content-Type: text/csv; filename="ywsarti.csv"

attached data
--=-1158308026-727155-3822-1761-1-=--
        EOS
        flexstub(Net::POP3).should_receive(:start).with('mail.ywesee.com', 110, 
          'data@bbmb.ch', 
          'test', Proc).and_return { |host, port, user, pass, block|
          pop = flexmock('pop')
          pop.should_receive(:each_mail).and_return { |block2|
            mail = flexmock('mail')
            mail.should_receive(:pop).and_return(src)
            mail.should_receive(:delete)
            block2.call(mail)
          }
          block.call(pop)
        }
        flexstub(BBMB::Util::Mail).should_receive(:notify_error)\
          .times(1).and_return { assert true }
        @mission.poll { |name, data|
          raise "some error"
        }
      end
    end
    class TestPollingManager < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @manager = PollingManager.new
        @datadir = File.expand_path('data', File.dirname(__FILE__))
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
