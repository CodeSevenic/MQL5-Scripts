#property copyright "Copyright 2023"
#property link      "https://www.mycompany.com"
#property version   "1.00"
#property strict

void OnStart() {
    // Deleting pending orders
    for(int i = OrdersTotal()-1; i >= 0; i--) {
        ulong ticket = OrderGetTicket(i);
        if(ticket > 0) {
            MqlTradeRequest request = {};
            MqlTradeResult result = {};
            
            request.action = TRADE_ACTION_REMOVE;
            request.symbol = _Symbol;
            request.order = ticket;
            
            OrderSend(request, result);
        }
    }

    // Closing open positions
    for(int i = PositionsTotal()-1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0) {
            MqlTradeRequest request = {};
            MqlTradeResult result = {};
            
            request.action = TRADE_ACTION_DEAL;
            request.symbol = _Symbol;
            request.volume = PositionGetDouble(POSITION_VOLUME);
            request.type_filling = ORDER_FILLING_IOC;
            request.deviation = 5;
            request.position = ticket;
            request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            request.type = ORDER_TYPE_SELL;
            
            OrderSend(request, result);
        }
    }
}
