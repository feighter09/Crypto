
install.packages('readxl')
install.packages('ggplot2')
install.packages('quantmod')
install.packages('forecast')

require(readxl)
require(quantmod)
require(ggplot2)
require(forecast)

#data pull
data = read_excel("~/crypto/daily_bitcoin_COINBASE.xlsx")
date = data$date
price = data$close


log_price = log(price)
log_returns = diff(log_price)



# all_days = seq(as.Date(start_date), as.Date(end_date), by = 'days')
# day_index = length(all_days) - days_timeframe+1
# days = all_days[day_index: length(all_days)]
# qplot(days,price) + geom_line() #plot prices
# qplot(days[2:length(days)], log_returns) + geom_line() #plot log returns



#plots
qplot(date,price)
qplot(date, log_price)
qplot(date, log_returns)



arima_model = auto.arima(log_price)































