#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\grid-bot\common\CommonFunction.mqh>

extern int gridBuyTopInput;
extern int gridSellLimitInput;
extern int gridBuyLimitInput;
extern int gridSellTopInput;

extern int gridBuyTopNotTPInput;
extern int gridSellTopNotTPInput;

extern double gridSLInput;
extern double volumeInput;
extern double gridAmountInput;

extern int gridTotalGlobal;
extern double gridStartGlobal;
extern bool isCreateBuyTopGlobal;
extern bool isCreateSellTopGlobal;

string typeBuyStr = "BUY";
string typeSellStr = "SELL";

void CreateOrderAction() {
   if (gridBuyLimitInput > 0) {
      int start = gridSellTopInput + 1;
      int end = start + gridBuyLimitInput - 1;
      for (int i = start; i <= end; i++) {
         createOrder(i, typeBuyStr);
      }
   }
   
   if (gridSellLimitInput > 0) {
      int start = gridSellTopInput + gridBuyLimitInput + 1;
      int end = start + gridSellLimitInput - 1;
      for (int i = start; i <= end; i++) {
         createOrder(i, typeSellStr);
      }
   }
   
   if (isCreateSellTopGlobal && gridSellTopInput > 0) {
      for (int i = GetStartGridSellTop(); i <= GetEndGridSellTop(); i++) {
         createOrder(i, typeSellStr);
      }
   }
   
   if (isCreateBuyTopGlobal && gridBuyTopInput > 0) {
      for (int i = GetStartGridBuyTop(); i <= GetEndGridBuyTop(); i++) {
         createOrder(i, typeBuyStr);
      }
   }
}

bool isExistGridNumber(int gridNumber) {
   double price = GetPriceByGridNumber(gridNumber);
   double minPrice = price - (gridAmountInput / 2);
   double maxPrice = price + (gridAmountInput / 2);

   int totalOrder = OrdersTotal();
   for (int i = 0; i < totalOrder; i++) {
      ulong orderTicket = OrderGetTicket(i);
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      if (orderPrice > minPrice && orderPrice < maxPrice) {
         return true;
      }
   }
   
   int totalPosition = PositionsTotal();
   for (int i = 0; i < totalPosition; i++) {
      ulong positionTicket = PositionGetTicket(i);
      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      if (positionPrice > minPrice && positionPrice < maxPrice) {
         return true;
      }
   }
   return false;
}

bool isGridHasTP (int gridNumber) {
   if (gridBuyTopNotTPInput > 0) {
      int endBuy = GetEndGridBuyTop();
      if (gridNumber > (endBuy - gridBuyTopNotTPInput) && gridNumber <= endBuy) {
         return false;
      }
   }
   
   if (gridSellTopNotTPInput > 0) {
      int startSell = GetStartGridSellTop();
      if (gridNumber >= startSell && gridNumber < (startSell + gridSellTopNotTPInput)) {
         return false;
      }
   }
   return true;
}

void createOrder(int gridNumber, string typeStr) {
   if (isExistGridNumber(gridNumber)) {
      //Print("Grid has exits: ", gridNumber);
      return;
   }

   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double price = GetPriceByGridNumber(gridNumber);
   double sl;
   double tp;
   ENUM_ORDER_TYPE type;
   
   if (typeStr == typeSellStr) {
      sl = GetPriceByGridNumber(gridTotalGlobal) + gridSLInput;
      tp = price - gridAmountInput;
      if (price > bidPrice) {
         type = ORDER_TYPE_SELL_LIMIT;
      } else {
         type = ORDER_TYPE_SELL_STOP;
      }
   } else {
      sl = gridStartGlobal - gridSLInput;
      tp = price + gridAmountInput;
      if (price < askPrice) {
         type = ORDER_TYPE_BUY_LIMIT;
      } else {
         type = ORDER_TYPE_BUY_STOP;
      }
   }
   
   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   request.action = TRADE_ACTION_PENDING;
   request.symbol = _Symbol;
   request.volume = volumeInput;
   request.type = type;
   request.price = price;
   if (gridSLInput > 0) {
      request.sl = sl;
   }
   if (isGridHasTP(gridNumber)) {
      request.tp = tp;
   }
   request.comment = "Grid No." + IntegerToString(gridNumber);
   
   if (OrderSend(request, result)) {
      Print("Create Order Success: Type: ", EnumToString(type), " - Ticket: ", result.order, " - Grid Number: ", gridNumber, " - Price: ", price, " - SL: ", sl, " - TP: ", tp);
   } else {
      Print("Create Order Error: Type: ", EnumToString(type), " - Comment: ", result.comment, " - Grid Number: ", gridNumber, " - Price: ", price, " - SL: ", sl, " - TP: ", tp);
   }
   Sleep(1000);
}
