require "spec_helper"

describe Scamp do
  before do
    @valid_params = {:api_key => "6124d98749365e3db2c9e5b27ca04db6", :subdomain => "oxygen"}
  end

  describe "#initialize" do
    it "should work with valid params" do
      a(Scamp).should be_a(Scamp)
    end
    it "should warn if given an option it doesn't know" do
      mock_logger

      a(Scamp, :fred => "estaire").should be_a(Scamp)

      logger_output.should =~ /WARN.*Scamp initialized with :fred => "estaire" but NO UNDERSTAND!/
    end
  end

  describe "#verbose" do
    it "should default to false" do
      a(Scamp).verbose.should be_false
    end
    it "should be overridable at initialization" do
      a(Scamp, :verbose => true).verbose.should be_true
    end
  end

  describe "#logger" do
    context "default logger" do
      before { @bot = a Scamp }
      it { @bot.logger.should be_a(Logger) }
      it { @bot.logger.level.should be == Logger::INFO }
    end
    context "default logger in verbose mode" do
      before { @bot = a Scamp, :verbose => true }
      it { @bot.logger.level.should be == Logger::DEBUG }
    end
    context "overriding default" do
      before do
        @custom_logger = Logger.new("/dev/null")
        @bot = a Scamp, :logger => @custom_logger
      end
      it { @bot.logger.should be == @custom_logger }
    end
  end

  describe "#first_match_only" do
    it "should default to false" do
      a(Scamp).first_match_only.should be_false
    end
    it "should be settable" do
      a(Scamp, :first_match_only => true).first_match_only.should be_true
    end
  end

  describe "private methods" do

    describe "#process_message" do
      before do
        @bot = a Scamp
        $attempts = 0 # Yes, I hate it too. Works though.
        @message = {:body => "my message here"}

        @bot.behaviour do
          2.times { match(/.*/) { $attempts += 1 } }
        end
      end
      after { $attempts = nil }
      context "with first_match_only not set" do
        before { @bot.first_match_only.should be_false }
        it "should process all matchers which attempt the message" do
          @bot.send(:process_message, @message)
          $attempts.should be == 2
        end
      end
      context "with first_match_only set" do
        before do
          @bot.first_match_only = true
          @bot.first_match_only.should be_true
        end
        it "should only process the first matcher which attempts the message" do
          @bot.send(:process_message, @message)
          $attempts.should be == 1
        end
      end
    end


  end

  def a klass, params={}
    params ||= {}
    params = @valid_params.merge(params) if klass == Scamp
    klass.new(params)
  end

  # Urg
  def mock_logger
    @logger_string = StringIO.new
    @fake_logger = Logger.new(@logger_string)
    Scamp.any_instance.should_receive(:logger).and_return(@fake_logger)
  end

  # Bleurgh
  def logger_output
    str = @logger_string.dup
    str.rewind
    str.read
  end
end
