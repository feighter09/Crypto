{install.packages('quantmod')
  install.packages('ggplot2')
  install.packages('forecast')
  install.packages('readxl')
  
  require(readxl)
  require(quantmod)
  require(ggplot2)
  require(forecast)
}

arima_strat = function(data, date_start_index, days_timeframe){
  
  
  # getSymbols(stock_ticker, src = 'google', from = date - days_timeframe, to = date) 
  
  # t.first <- species[match(unique(species$Taxa), species$Taxa),]
  date_end_index = date_start_index+days_timeframe
  data_into_model = data[date_start_index:date_end_index,]
  
  price = data_into_model$close
  
  log_price = log(price)
  log_returns = diff(log_price)
  
  # all_days = seq(as.Date(start_date), as.Date(end_date), by = 'days')
  # day_index = length(all_days) - days_timeframe+1
  # days = all_days[day_index: length(all_days)]
  # qplot(days,price) + geom_line() #plot prices
  # qplot(days[2:length(days)], log_returns) + geom_line() #plot log returns
  
  arima_model = auto.arima(log_price)
  # summary(arima_model)
  
  pred_log_return = forecast(arima_model,1)
  pred_price = exp(as.numeric(pred_log_return$mean))
  
  pred_profit = pred_price - price[length(price)]
  return(pred_profit)
}

perform_strat = function(data, start_date, days_timeframe, length_testing){


  array_pnl = c()
  date_start_index = match(start_date, data$date)
  for(i in 0:length_testing){
    date_start_index = date_start_index +1
    
    pred_profit = arima_strat(data, date_start_index, days_timeframe)
    array_pnl = c(array_pnl, pred_profit)
  }
  
  return(array_pnl)
}

data = read_excel("~/crypto/daily_bitcoin_COINBASE.xlsx")
date = data$date
price = data$close
returns = diff(price)
log_returns = log(returns)

start_date = date[1]
days_timeframe = 100
length_days = length(date)
length_testing = length_days - days_timeframe -2


model_pnl = perform_strat(data, start_date, days_timeframe, length_testing)
buy_sell = sign(sign(model_pnl)-1)+1 #converts price predictions into binary actions. 1 = buy/hold, 0 = sell/do nothing


true_returns = returns[1:(length_testing+1)]

strategy_returns_daily = buy_sell*true_returns
strategy_returns = sum(buy_sell * true_returns)










