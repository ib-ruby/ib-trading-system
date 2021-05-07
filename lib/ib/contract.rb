module IB
  class Contract
    def request_historic_data back: "10 D", interval: :hour1

       ib = Connection.current
       ib.send_message IB::Messages::Outgoing::RequestHistoricalData.new(
                      contract: self,
#                     end_date_time: Time.now.to_ib,
                      duration: back, #    ?
                      bar_size: interval, #  IB::BAR_SIZES.key(:hour)?
                      what_to_show: :trades,
                      use_rth: 1,
                      keep_up_todate: 1)    # if set to `1` here, comment end_date_time
    end
  end
end
