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
double gridAmountInput = 50 * _Point;
int limitPositionInput = 10;
// -- Input End ----------------------------

// Global
double numberStartGridGlobal = 0;
double priceStartGridGlobal = 0;
int differenceBuyAndSellGlobal = 0; // Nếu value > 0 => Buy > Sell

int OnInit() {
   //RemoveOrderAll();

   if (gridTotalInput % 2 != 0) {
      Print("Grid total invalid.");
      ExpertRemove();
      return(INIT_SUCCEEDED);
   }

   Print("Start bot");
   
   MainFuction();
   
   EventSetTimer(10);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   Print("EA đã bị gỡ bỏ, lý do: ", reason);
}

void OnTimer() {
   MainFuction();
}

void MainFuction() {
   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double startByBid = GetNumberStartGrid(bidPrice);
   double startByAsk = GetNumberStartGrid(askPrice);
   if (startByBid != startByAsk) {
      return;
   }
   
   numberStartGridGlobal = startByBid;
   priceStartGridGlobal = numberStartGridGlobal * gridAmountInput;
   
   int totalPosition = PositionsTotal();
   if (totalPosition > 0) {
      int totalPositionBuy = GetTotalPositionBuy();
      int totalPositionSell = GetTotalPositionSell();
      
      int differenceBuyAndSellNew = totalPositionBuy - totalPositionSell;
      if (differenceBuyAndSellNew != differenceBuyAndSellGlobal) {
         differenceBuyAndSellGlobal = differenceBuyAndSellNew;
         Print("Total lệnh: ", totalPosition, " - Lệnh Buy: ", totalPositionBuy, " - Lệnh Sell: ", totalPositionSell);
      }
   }
   
   RemoveOrderAction();
   CreateOrderAction();
}

void OnTick() {}
