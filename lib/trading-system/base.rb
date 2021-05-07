

module TradingSystem

  RawData =  Struct.new :time, :signal, :price, :prev, :actual, :result

  class Base
    # implements a very simple variant of a mechanical trend surving trading system

#    Time=0  ..  Market Open
#    Time=1  ... Pull previous hour historical data...=> Obtain Pivot Point & Slope.
#
#    If slope (of Pivot-Points) is positive then BUY.
#    If slope                   is negative then SELL
#
#    repeat every hour

    include Support::Logging

    attr_reader :contract

    def initialize contract:, default_size: 1, **params

      @ready_historical_data = Queue.new
      @ready_data = Queue.new
      @cum_result = 0
      @current_price_signal = 0
      @raw_data = []
      @contract = contract
      @default_size = default_size
      @subscribers = []
      add_subscribers
    end

    def stop
      C.send_message :CancelHistoricalData, id: @request_id
      C.unsubscribe *@subscribers
    end

    def run 

      if @contract.verify.first.nil?
        raise "Invalid Contract"
      end

      @request_id = @contract.request_historic_data back: "10 D", interval: :hour1

      loop do
        data_received =  @ready_historical_data.pop  #   blocks until historical data received
      end

      sleep 60; stop
      loop do

        recent_data =  @ready_data.pop  #   blocks until data received
        analyse_data recent_data
        @contract.bars << recent_data


      end
    end  # run

    def add_subscribers
      ## subscribe to TWS Messages
      ## save historical data in Contract.bars
      recent_bar = nil
      @subscribers << C.subscribe(IB::Messages::Incoming::HistoricalData) do |msg|
        if msg.request_id == @request_id
          msg.results.each { |entry| logger.info "#{contract.symbol}->#{entry}" }
          msg.results.each{| bar| analyse_data(bar); @contract.bars << bar  }
          @ready_historical_data.push Time.now
        end
      end

      # get actual data, display each incomming dataframe, store the data in `recent_bar`
      #
      # A new bar is indicated by a change of the `time`-attribute of the received bar
      # and by `volume=0` 
      File.open("../log/points", "w+"){|f| f.puts "Start @ #{Time.now}"}
      @subscribers << C.subscribe( IB::Messages::Incoming::HistoricalDataUpdate) do |msg|
        if msg.request_id == @request_id
          if recent_bar.present? && msg.bar.time > recent_bar.time
            logger.info "#{contract.symbol} -------------- New Bar -----------------------"
            logger.info "#{contract.symbol}->#{recent_bar.to_human}" 
            @ready_data.push recent_bar unless recent_bar.nil?
          end

          File.open('../log/points','a'){|f| f.puts "#{@contract.symbol} -> #{msg.bar.to_human}" }
          recent_bar = msg.bar
        end
      end
    end
    ## overload !
    def analyse_data data

    end

  end
end
