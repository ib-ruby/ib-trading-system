

module TradingSystem


  class Surfing < Base
    # implements a very simple variant of a mechanical trend surving trading system

#    Time=0  ..  Market Open
#    Time=1  ... Pull previous hour historical data...=> Obtain Pivot Point & Slope.
#
#    If slope (of Pivot-Points) is positive then BUY.
#    If slope                   is negative then SELL
#
#    repeat every hour


    attr_reader :raw_data, :current_price_signal


    ## data.price_signal :  Backtesting facility to determine the execution-price
    #                       Method is defined in ib/bar.rb
    #
    def analyse_data data, training:  true
        if @contract.bars.size <= 1
          @current_price_signal = data.close
        else
          signal = (-(@contract.bars.last.pivot[:pp] - data.pivot[:pp]) <=> 0 )
          if !@raw_data.empty? && @raw_data.last[:signal] != signal
            @cum_result += (@current_price_signal - data.price_signal(signal).round(2)) * signal
            action = signal == 1 ? :buy : :sell
            @current_price_signal = data.price_signal( signal ).round(2)
            if training
              logger.info "#{data.time.strftime("%X")} #{@contract.symbol} -> would fire a #{action}-order @ #{data.close}  result: #{@cum_result}"
            else  #--------- change to place to execute the orders -------
              logger.info "#{data.time.strftime("%X")} #{@contract.symbol} ->: FIRE a #{action}-order @ #{data.close}  result: #{@cum_result}"
              G.clients.first.preview contract: @contract,
                order: Limit.order( size: @default_size, action: action, price: data.close  )
            end
          else
            # just print the actual signal
            logger.info "#{data.time.strftime("%X")} #{@contract.symbol}  --> #{signal <0 ? "still short" : "still long"}         #{data.close}"
          end
          @raw_data.push( RawData.new  data.time,
                               signal,
                               data.close,
                               @contract.bars.last.pivot[:pp].round(2),
                               data.pivot[:pp].round(2),
                               @cum_result )
          #  verbose output
          out =  @raw_data.last
        end

    end
  end
end
