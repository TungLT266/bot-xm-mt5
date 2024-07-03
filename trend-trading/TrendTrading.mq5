#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\trend-trading\common\CommonFunction.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\trend-trading\common\CreateOrderAction.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\trend-trading\common\RemoveOrderAction.mqh>

// Input
// -- Input Start ----------------------------
int gridTotalInput = 10; // Số chẵn
double volumeInput = 0.01;
double gridAmountInput = 35 * _Point;
// -- Input End ----------------------------

// Global
double priceStartGridGlobal = 0;

int OnInit() {
   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   Print("Start bot: Bid: ", bidPrice, " - Ask: ", askPrice);
   
   priceStartGridGlobal = GetPriceStartGrid(bidPrice);
   
   CreateOrderAction();
   
   EventSetTimer(10);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   Print("EA đã bị gỡ bỏ, lý do: ", reason);
}

void OnTimer() {
   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   priceStartGridGlobal = GetPriceStartGrid(bidPrice);
   
   RemoveOrderAction();
   CreateOrderAction();
}

void OnTick() {}
