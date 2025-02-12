#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

// Input
double volumeInput = 0.1;
double priceInput = 33 * _Point;
double testInput = 31 * _Point;

int OnInit() {
   CreateOrder();

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   Print("EA đã bị gỡ bỏ, lý do: ", reason);
}

void OnTick() {

}

void CreateOrder() {
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID) + priceInput;
   
   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   request.action = TRADE_ACTION_PENDING;
   request.symbol = _Symbol;
   request.volume = volumeInput;
   request.type = ORDER_TYPE_BUY_STOP;
   request.price = price ;
   //request.sl = sl;
   request.tp = price + testInput;
   //request.deviation = deviation;
   
   if (OrderSend(request, result)) {
      Print("Create Order Success");
   } else {
      Print("Create Order Error: ", result.comment);
   }
}
