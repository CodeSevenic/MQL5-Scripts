#property copyright "Copyright 2023, Sibusiso Shongwe"
#property link      "https://www.mycompany.com"
#property version   "1.00"
#property strict

double StopDistance = 100; // Stop distance in pips
int MagicNumber = 101; // Unique identifier for EA's orders
double LotSize = 0.03; // Lot size for each trade
double stopLoss = 50; // Stop loss distance in pips
double takeProfit = 300; // Take profit distance in pips

void OnStart()
{
    // Point value adjustment factor
    double pointAdjustment = 1.0;
    
    // Adjusting StopDistance and point value for non-Forex pairs
    if(StringFind(_Symbol, "XAU") >= 0 || StringFind(_Symbol, "NAS") >= 0) {
        StopDistance *= 10;
        pointAdjustment = 10.0;
    }

    double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK); // Current ask price
    double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID); // Current bid price
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE); // Minimum price change

    // Get the broker's minimum stop level and convert to pips
    double minStopLevelPips = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point * pointAdjustment;

    // Ensure that stopLoss and takeProfit are at least minStopLevelPips away from the current price
    if(stopLoss < minStopLevelPips) stopLoss = minStopLevelPips;
    if(takeProfit < minStopLevelPips) takeProfit = minStopLevelPips;

    string comment = "Sibs is trading";
      
    //Price must be normalized either to digits or tickSize
    askPrice = NormalizeDouble(askPrice/tickSize, _Digits) * tickSize; // Normalizing ask price
    bidPrice = NormalizeDouble(bidPrice/tickSize, _Digits) * tickSize; // Normalizing bid price

    // Request and Result Declaration and Initialization
    MqlTradeRequest buy_request = {};
    MqlTradeResult buy_result = {};
     
    MqlTradeRequest sell_request = {};
    MqlTradeResult sell_result = {};

    // Calculate the price levels for buy and sell orders
    double sell_price = bidPrice - StopDistance * _Point; 
    double buy_price = askPrice + StopDistance * _Point;

    //Calculate the stopLoss and takeProfit levels for buy and sell orders
    double buy_sl = buy_price - stopLoss * _Point * pointAdjustment;
    double sell_sl = sell_price + stopLoss * _Point * pointAdjustment;
    double buy_tp = buy_price + takeProfit * _Point * pointAdjustment;
    double sell_tp = sell_price - takeProfit * _Point * pointAdjustment;

    // Filling in the order request structures
    buy_request.action = TRADE_ACTION_PENDING;
    buy_request.type = ORDER_TYPE_BUY_STOP;
    buy_request.symbol = _Symbol;
    buy_request.volume = LotSize;
    buy_request.price = buy_price;
    //buy_request.sl = buy_sl; // Setting stop loss for buy order
    buy_request.tp = buy_tp; // Setting take profit for buy order
    buy_request.deviation = 10;
    buy_request.magic = MagicNumber;
    buy_request.comment = comment;

    sell_request.action = TRADE_ACTION_PENDING;
    sell_request.type = ORDER_TYPE_SELL_STOP;
    sell_request.symbol = _Symbol;
    sell_request.volume = LotSize;
    sell_request.price = sell_price;
   // sell_request.sl = sell_sl; // Setting stop loss for sell order
    sell_request.tp = sell_tp; // Setting take profit for sell order
    sell_request.deviation = 10;
    sell_request.magic = MagicNumber;
    sell_request.comment = comment;

    //Sending the order requests
    OrderSend(buy_request, buy_result);
    OrderSend(sell_request, sell_result);
}
