#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5\Experts\bot-ea\grid-bot\common\CommonFunction.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5\Experts\bot-ea\grid-bot\common\CreateOrderAction.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\53785E099C927DB68A545C249CDBCE06\MQL5\Experts\bot-ea\grid-bot\common\RemoveOrderAction.mqh>

// Input
int gridBuyNumberInput = 5;
int gridBuyAndSellNumberInput = 0;
int gridSellNumberInput = 5;
double volumeInput = 0.01;
double gridCenterInput = 6187000 * _Point;
double gridAmountInput = 6000 * _Point; // Số chẵn
double gridSLInput = 10000 * _Point;

// Global
double gridStartGlobal = 0;
int gridTotalGlobal = 0;

int OnInit() {
   gridTotalGlobal = gridBuyNumberInput + gridBuyAndSellNumberInput + gridSellNumberInput;
   gridStartGlobal = gridCenterInput - (gridAmountInput / 2) - (gridAmountInput * ((gridTotalGlobal / 2) - 1));
   
   Print("OnInit: Point: ", _Point, " - Grid Center: ", gridCenterInput, " - Grid Buy: ", gridBuyNumberInput, " - Grid Mid: ", gridBuyAndSellNumberInput,
          " - Grid Sell: ", gridSellNumberInput, " - Grid Amount: ", gridAmountInput,
         " - Volume: ", volumeInput, " - Grid SL: ", gridSLInput, " - Grid Start: ", gridStartGlobal);
         
   RemoveOrderAction();
   CreateOrderAction();
   
   EventSetTimer(10);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   Print("EA đã bị gỡ bỏ, lý do: ", reason);
}

void OnTimer() {
   CreateOrderAction();
   
   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double slDown = GetPriceByGridNumber(1) - gridSLInput;
   double slUp = GetPriceByGridNumber(gridTotalGlobal) + gridSLInput;
   if (bidPrice > slUp || bidPrice < slDown) {
      Print("Stop bot: ", bidPrice);
      RemoveOrderAction();
      ExpertRemove();
   }
}

void OnTick() {}
