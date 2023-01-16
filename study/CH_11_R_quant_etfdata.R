library("quantmod")
library(magrittr)
library("PerformanceAnalytics")

symbols = c("SPY", 'IEV', 'EWJ', 'EEM', 'TLT', 'IEF', 'IVR',
            'RWX', 'GLD', 'DBC')
getSymbols(symbols, src = "yahoo")
prices = do.call(cbind, lapply(symbols, function(x) Ad(get(x)))) %>% setNames(symbols)
rets = Return.calculate(prices) %>% na.omit()

write.csv(prices,"etf_price.csv", row.names = F)
write.csv(rets,"etf_return.csv")

?write.csv

head(prices)
index(prices)
