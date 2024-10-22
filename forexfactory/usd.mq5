#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5\Experts\bot-ea\forexfactory\common\ModifyOrderStopAction.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5\Experts\bot-ea\forexfactory\common\ModifyPositionSLAction.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5\Experts\bot-ea\forexfactory\common\RemoveOrderAction.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5\Experts\bot-ea\forexfactory\common\CreateOrderStopAction.mqh>

// Input
double volumeInput = 0.03;
ulong deviationInput = 10;
double stopPriceRateInput = 33 * _Point;
double stopPriceSLRateInput = 31 * _Point;
double stopPriceTPRateInput = 400 * _Point;
double maxModifyPriceInput = 5 * _Point;
double minModifyPriceInput = 5 * _Point;

int OnInit() {
   Print("OnInit: Point: ", _Point, " - Rate stop: ", stopPriceRateInput, " - Rate SL: ", stopPriceSLRateInput, " - Rate TP: ", stopPriceTPRateInput,
         " - Volume: ", volumeInput, " - Min modify: ", minModifyPriceInput, " - Max modify: ", maxModifyPriceInput);

   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   Print("OnInit: Bid: ", bidPrice, " - Ask: ", askPrice);
   
   CreateOrderStopAction(bidPrice, askPrice, ORDER_TYPE_BUY_STOP);
   CreateOrderStopAction(bidPrice, askPrice, ORDER_TYPE_SELL_STOP);
   
   EventSetTimer(1);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   Print("EA đã bị gỡ bỏ, lý do: ", reason);
}

void OnTimer() {
   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   Print("OnTimer: Giá mua: ", bidPrice, " - Giá bán: ", askPrice);
   
   RemoveOrderAction();
   //ModifyOrderStopAction(bidPrice, askPrice);
   //ModifyPositionSLAction(bidPrice, askPrice);
   
   //ExpertRemove();
}

void OnTick() {}
