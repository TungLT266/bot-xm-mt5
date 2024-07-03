#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\grid-bot\common\CommonFunction.mqh>

extern int gridBuyNumberInput;
extern int gridSellNumberInput;
extern double gridSLInput;
extern double volumeInput;
extern double gridAmountInput;

extern int gridTotalGlobal;
extern double gridStartGlobal;

string typeBuyStr = "BUY";
string typeSellStr = "SELL";

void CreateOrderAction() {
   for (int i = 1; i <= gridBuyNumberInput; i++) {
      if (!isExistGridNumber(i)) {
         createOrder(i, typeBuyStr);
      }
   }
   
   for (int i = (gridBuyNumberInput + 1); i <= gridTotalGlobal; i++) {
      if (!isExistGridNumber(i)) {
         createOrder(i, typeSellStr);
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

void createOrder(int gridNumber, string typeStr) {
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
   request.tp = tp;
   request.comment = "Grid No." + IntegerToString(gridNumber);
   
   if (OrderSend(request, result)) {
      Print("Create Order Success: Type: ", EnumToString(type), " - Ticket: ", result.order, " - Grid Number: ", gridNumber, " - Price: ", price, " - SL: ", sl, " - TP: ", tp);
   } else {
      Print("Create Order Error: Type: ", EnumToString(type), " - Comment: ", result.comment, " - Grid Number: ", gridNumber, " - Price: ", price, " - SL: ", sl, " - TP: ", tp);
   }
}
