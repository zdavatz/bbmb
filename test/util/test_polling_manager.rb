require 'test_helper'
require 'fileutils'
require 'bbmb/util/polling_manager'

module BBMB
  module Util
    class TestFileMission < Minitest::Test
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
      include FlexMock::TestCase
      def setup
        @datadir = File.expand_path('../data', File.dirname(__FILE__))
        BBMB.config = flexmock('config')
        BBMB.config.should_receive(:bbmb_dir).and_return(@datadir)
        @mission = FtpMission.new
        @mission.directory = "ftp://user:pass@ftp.server.com/path/to/dir"
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
      include FlexMock::TestCase
      def setup
        @mission = PopMission.new
        @mission.host = "mail.ywesee.com"
        @mission.user = "data@bbmb.ch"
        @mission.pass = "test"
      end
      def test_poll_message__normal
        skip "Must fix  test_poll_message__normal using the mail gem"
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
        skip "Must fix  test_poll_message__many_parameters using the mail gem"
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
        skip "Must fix  test_poll_message__no_quotes using the mail gem"
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
        mail = flexmock('mail')
        mail.should_receive(:pop).and_return(src)
        mail.should_receive(:mark_for_delete=).with(true)
        mail.should_receive(:multipart?).and_return(true)
        mail.should_receive(:parts).and_return([])
        flexstub(::Mail).should_receive(:delivery_method).and_return(
          ::Mail::TestMailer.new({}))
        flexstub(::Mail::TestMailer).should_receive(:deliveries)
          .and_return([mail])
        flexstub(Net::POP3).should_receive(:start).with(
          'mail.ywesee.com',
          110,
          'data@bbmb.ch',
          'test', Proc
        ).and_return { |host, port, user, pass, block|
          pop = flexmock('pop')
          pop.should_receive(:each_mail).and_return { |block2|
            block2.call(mail)
          }
          block.call(pop)
        }
        # check nothing raised
        assert_equal([mail],  @mission.poll(&lambda {|name| }))
      end
      def test_poll__error
        skip "Must fix  test_poll__error using the mail gem"
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
    class TestPopMissionXmlConv < ::Minitest::Test
      def setup
        @popserver = TCPServer.new('127.0.0.1', 0)
        addr = @popserver.addr
        @mission = PopMission.new
        @mission.host = 'localhost'
        @mission.port = addr.at(1)
        @mission.user = "testuser"
        @mission.pass = "test"
        @mission.content_type = "text/xml"
        @datadir = File.expand_path('data', File.dirname(__FILE__))
      end
      def teardown
        FileUtils.rm_r(@datadir)
      end
      def test_poll
        options = { :from =>  'you@you.com', }
        ::Mail.defaults do delivery_method :test, options end
        skip "Must add a test using the mail gem"
        mail = ::Mail.read(File.join(TestData, 'simple_email.txt'))
        mail.deliver
        mail = ::Mail.read(File.join(TestData, 'sandoz.xundart@bbmb.ch.20110524001038.928592'))
        mail.deliver
        nr_messages = 2
        assert_equal(nr_messages, ::Mail::TestMailer.deliveries.length)
        counter = 0
        @mission.poll do |transaction|
          counter += 1
          assert_instance_of(Util::Transaction, transaction)
          next if /testuser@localhost/.match(transaction.origin)
          expected = %(<?xml version=\"1.0\"?>
<foo>
  <bar/>
</foo>
)
          assert_equal(expected, transaction.input)
          assert_equal("pop3:testuser@localhost:#{@mission.port}",
                        transaction.origin)
          assert_equal('Reader', transaction.reader)
          assert_equal('Writer', transaction.writer)
          dest = transaction.destination
          assert_instance_of(Util::DestinationHttp, dest)
          assert_equal('http://foo.bar.baz:2345', dest.uri.to_s)
        end
        assert_equal(nr_messages, counter,  "poll-block should have been called exactly #{nr_messages} times")
      end
      def teardown
        @popserver.close
      end
    end
    class TestPollingManager < Minitest::Test
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
