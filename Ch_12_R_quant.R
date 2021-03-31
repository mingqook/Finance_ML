install.packages("PerformanceAnalytics")
install.packages("timeSeries")
library(quantmod)
library(PerformanceAnalytics)
library(magrittr)
library(timeSeries)

ticker = c('SPY','TLT')
getSymbols(ticker)
prcies = do.call(cbind, lapply(ticker, function(x) Ad(get(x))))
rets = Return.calculate(prcies) %>% na.omit()
cor(rets)

portfolio = Return.portfolio(R = rets, weights = c(0.6, 0.4), 
                             rebalance_on = 'years', verbose = T)
portfolio$BOP.Weight

portfolios = cbind(rets, portfolio$returns) %>% setNames(c('주식', '채권', '60대40'))
charts.PerformanceSummary(portfolios, main = "60대40포트폴리오")

turnover = xts(rowSums(abs(portfolio$BOP.Weight - timeSeries::lag(portfolio$EOP.Weight)), na.rm = T), 
               order.by = index(portfolio$BOP.Weight))
chart.TimeSeries(turnover)

symbols = c('SPY', 'SHY')
getSymbols(symbols)
prices = do.call(cbind, lapply(symbols, function(x) Ad(get(x))))
rets = na.omit(Return.calculate(prices))

ep = endpoints(rets, on = 'months')
wts = list()
lookback = 10

for(i in (lookback+1) : length(ep)){
  sub_price = prices[ep[i-lookback] : ep[i], 1]
  head(sub_price)
  sma = mean(sub_price)
  wt = rep(0, 2)
  wt[1] = ifelse(last(sub_price) > sma, 1, 0)
  wt[2] = 1-wt[1]
  wts[[i]] = xts(t(wt), order.by = index(rets[ep[i]]))
}

wts = do.call(rbind, wts)

Tactical = Return.portfolio(rets, wts, verbose = T)
portfolios = na.omit(cbind(rets[,1], Tactical$returns)) %>%
  setNames(c('매수 후 보유', '시점 선택 전략'))
charts.PerformanceSummary(portfolios)
