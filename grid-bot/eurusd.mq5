#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\grid-bot\common\CommonFunction.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\grid-bot\common\CreateOrderAction.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\grid-bot\common\RemoveOrderAction.mqh>

// Input
// -- Input Start ----------------------------
int gridBuyTopInput = 2;
int gridSellLimitInput = 2;
int gridBuyLimitInput = 2;
int gridSellTopInput = 2;

double volumeInput = 0.01;
double gridCenterInput = 1.07641 + (35 * 8 * _Point);
double gridAmountInput = 35 * _Point;
double gridSLInput = 0 * _Point;
double botStopPriceInput = 50 * _Point;
// -- Input End ----------------------------

// Global
double gridStartGlobal = 0;
int gridTotalGlobal = 0;

int OnInit() {
   gridTotalGlobal = gridSellTopInput + gridBuyLimitInput + gridSellLimitInput + gridBuyTopInput;
   gridStartGlobal = gridCenterInput - ((gridBuyLimitInput + gridSellTopInput) * gridAmountInput);
   
   Print("Grid Buy Limit: ", gridBuyLimitInput, " - Grid Sell Limit: ", gridSellLimitInput, " - Grid Buy Top: ", gridBuyTopInput, " - Grid Sell Top: ", gridSellTopInput);
   Print("OnInit: Point: ", _Point, " - Grid Center: ", gridCenterInput,
          " - Grid Amount: ", gridAmountInput,
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
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double stopDown = GetPriceByGridNumber(1) - botStopPriceInput;
   double stopUp = GetPriceByGridNumber(gridTotalGlobal) + botStopPriceInput;
   if (bidPrice > stopUp || askPrice < stopDown) {
      Print("Stop bot: Bid: ", bidPrice, " - Ask: ", askPrice);
      RemoveOrderAction();
      ExpertRemove();
   }
}

void OnTick() {}
