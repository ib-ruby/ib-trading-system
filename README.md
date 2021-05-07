# A concept study for automated trading in ruby

During the 1980th, mechanical trading systems were very popular.
For the first time, computerized trading of stocks and commodities was possible. 

Due to the high intrinsic entropy of time series data of financial assets, most efforts failed.

Today mechanical trading systems are mostly used for educational purpose. 


In 2020 we witnessed a comeback of private traders to the US-market. This leads to the question,
whether common price-pattern of the past re-emerged as well.  
If this hypothesis is valid, old school **A**utomated **T**rading **S**ystems could even today
offer a decent support for trading decisions.


#
>The easiest way to install the `IB-Ruby`-environment is to use an [IB-Container](https:/github.com/ib-ruby/ib-container). Clone this repository there, run `bundle install` and  `bundle update` and you are ready to go.

# IB-Trading-System

The `IB-Trading-System` regularly uses the `TWS-API` as data source to compile trading signals. 
No further database is required. 


```ruby
> ats = TradingSystem::Base.new contract: Symbols::Futures.mini_dax, default_size: 1
> ats.run
```

initializes and starts the ATS. `TradingSystem::Base`, however,  just provides the framework
for the trading system. _Real_ trading systems are children of the base-class.

For demonstration purpose, `TradingSystem::Surfing` is included. It generates signals according
to the slope of the _Pivot-Points_ of the analysed time-series. 

### How does it work?
`IB-Trading-System` is integrated in `IB-Ruby`. It redefines and extends `IB::Model`-Classes.

* `lib/ib/bar.rb` reopens `IB::Bar` and defines  `price-signal`, which is used for backtesting. 
* `lib/ib/contract.rb`  reopens `IB::Contract` and defines a method `request_historical_data`. 

It takes tow parameter, `back`, the amount of data requested from the tws and `interval`, the timeframe of the trading-system, which is one of 
```ruby
> IB::BAR_SIZES
 "1 min", "5 mins", "15 mins", "30 mins", "1 hour", "1 day"

```

Prior to the processing of life-data, recent historical data **of the same timeframe** 
are analysed and trading signals are compiled. 
`Contract.request_historical_data`  just fires the request. The `TWS`-response is processed by `@subscribers`
in `TradingSystem::Base`. 

```ruby
@subscribers << C.subscribe(IB::Messages::Incoming::HistoricalData) do |msg|
          msg.results.each{| bar| analyse_data(bar); @contract.bars << bar  }
          @ready_historical_data.push Time.now
        end
```
There is almost no magic here. The data-analysis is delegated to `analyse_data` and received OHLC-Data
are added to `Contract.bars`.  Finally they are added to a thread-safe Queue. This signals
the main program to continue using linear processing. 

After collecting historical data, real-time data are received. They appear as quasi real-time
snapshot data and are transmitted as OHLC. Important: The time-field of the very first Bar is
used for all subsequently transmitted bars -- until the candle(stick) is completed. 
Every time, a candlestick is complete, `analyse_data` is called and trading rules are compiled.

### Analyse-Data

Centerpiece of each trading system is the method `analyse_data`. In simple cases, that's the
only method to define.
Its first parameter contains the most recent `IB::BAR` (received from the tws). Historical data
are present in `@contract.bars`.  Thus the most basic approach would be

```ruby
class Surfing < Base
  def analyse_data data
    signal = -(@contract.bars.last.pivot[:pp] - data.pivot[:pp]) <=> 0 
    @position ||= -signal
    if @position != signal
      action = signal == 1 ? :buy : :sell  
      IB::Gateway.current.clients.first place contract: @contract, 
                                            order: Limit.order( action: action, size: @default_size, price: data.close ) 
      @position = signal
    end
end

```
### Backtesting

`TradingSystem::Surfing` stores compiled trade-signals in `@raw_data`, which is publicly accessible, among others 
```ruby
> ats =  TradingSystem::Surfing.new contract: Symbols::Futures.mini_dax
> ats.run
> (...)
> ats.stop
> ats.contract.to_human               => "<Future: DAX 202106 EUR>" 
> ats.raw_data.first
  => #<struct TradingSystem::RawData time=2021-04-23 02:00:00 +0000, 
                             signal=0, price=15274.0, prev=15275.33, actual=15275.33, result=0>

> ats.raw_data.result.to_i
[0, 0, 0, 8, -4, -4, -22, -22, -22, -25, -25, -25, -25, -19, -19, -20, -20,
-16, -14, -26, -26, -26, -29, -29, -29, -17, -17, -17, -17, 30, 30, 30, 37, 38,
38, 38, 38, 57, 61, 58, 58, 64, 53, 39, 39, 39, 39, 39, 79, 84, 84, 85, 70, 70,
70, 38, 20, 20, 20, 1, 1, -20, -20, -20, -1, -1, 1, 1, -28, -28, -28, -28, -28,
37, -22, -22, 8, 20, 15, 15, 15, 48, 48, 48, 48, 48, 95, 90, 42, 42, 42, 67,
67, 80, 80, 80, 76, 76, 76, 76, 76, 124, 124, 124, 158, 158, 155, 155, 140,
128, 128, 160, 160, 148, 148, 155, 155, 155, 142, 142, 142, 142, 142, 150, 150,
150, 150, 192, 192, 192, 192, 161, 161, 161, 129, -15, -15, -15, -15, -15, 195,
195, 195, 195, 195, 195, 195, 292, 292, 280, 276, 281, 281, 281, 281, 379, 373,
373, 373, 439, 381, 381, 372, 376, 371, 377, 377, 377, 370, 370, 370, 342, 333,
282, 255, 255, 299, 299, 299, 299, 299, 246, 246, 241, 234, 234, 234, 280, 257,
238, 238, 234, 234, 234, 234, 234] 
> 
```
The data are stored in an array of structs, acting as intelligent hash by default. 
`@raw_data` is a common Array. For further analysis, ruby offers [numo-narray](https://github.com/ruby-numo/numo-narray) and for complex tasks, a delegation to R. 


## CONTRIBUTING

If you want to contribute to IB-Trading-System development:

 * Make a fresh fork of IB-Tading-System (Fork button on top of Github GUI)
 * Clone your fork locally (git clone /your fork private URL/)
 * Add main ib-container repo as upstream (git remote add upstream https://github.com/ib-ruby/ib-trading-system.git)
 * Create your feature branch (git checkout -b my-new-feature)
 * Modify code as you see fit
 * Commit your changes (git commit -am 'Added some feature')
 * Pull in latest upstream changes (git fetch upstream -v; git merge upstream/master)
 * Push to the branch (git push origin my-new-feature)
 * Go to your Github fork and create new Pull Request via Github GUI





