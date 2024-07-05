#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\trend-trading\common\CommonFunction.mqh>
#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\trend-trading\common\RemoveOrderAction.mqh>

extern int gridTotalInput;
extern double volumeInput;
extern double gridAmountInput;

void CreateOrderAction() {
   int start = 1;
   int end = gridTotalInput;
   
   if (PositionsTotal() > limitPositionInput) {
      if (differenceBuyAndSellGlobal > 0) {
         end = gridTotalInput / 2;
      } else if (differenceBuyAndSellGlobal < 0) {
         start = (gridTotalInput / 2) + 1;
      } else {
         return;
      }
   }
   
   for (int i = start; i <= end; i++) {
      createOrder(i);
   }
}

bool isExistGridNumber(int gridNumber, ENUM_ORDER_TYPE type) {
   double price = GetPriceByGridNumber(gridNumber);
   double minPrice = price - (gridAmountInput / 2);
   double maxPrice = price + (gridAmountInput / 2);

   int totalOrder = OrdersTotal();
   for (int i = 0; i < totalOrder; i++) {
      ulong orderTicket = OrderGetTicket(i);
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      if (orderPrice > minPrice && orderPrice < maxPrice) {
         ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE) OrderGetInteger(ORDER_TYPE);
         if (orderType == type) {
            return true;
         } else {
            RemoveOrderByTicket(orderTicket);
            totalOrder--;
         }
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

void createOrder(int gridNo) {
   double price = GetPriceByGridNumber(gridNo);
   double tp;
   ENUM_ORDER_TYPE type;
   
   if (gridNo > (gridTotalInput / 2)) {
      type = ORDER_TYPE_BUY_STOP;
      tp = price + gridAmountInput;
      if (differenceBuyAndSellGlobal > 0) {
         if (gridNo <= (gridTotalInput / 2) + differenceBuyAndSellGlobal + 1) {
            type = ORDER_TYPE_SELL_LIMIT;
            tp = price - gridAmountInput;
         }
      }
   } else {
      type = ORDER_TYPE_SELL_STOP;
      tp = price - gridAmountInput;
      if (differenceBuyAndSellGlobal < 0) {
         if (gridNo > (gridTotalInput / 2) + differenceBuyAndSellGlobal - 1) {
            type = ORDER_TYPE_BUY_LIMIT;
            tp = price + gridAmountInput;
         }
      }
   }
   
   if (isExistGridNumber(gridNo, type)) {
      return;
   }
   
   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if (type == ORDER_TYPE_SELL_LIMIT || type == ORDER_TYPE_BUY_LIMIT) {
      if (price >= bidPrice && price <= askPrice) {
         Print("Create order failure.");
         return;
      }
   } else if (price >= (bidPrice - (gridAmountInput / 2)) && price <= (askPrice + (gridAmountInput / 2))) {
      Print("Create order failure.");
      return;
   }
   
   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   request.action = TRADE_ACTION_PENDING;
   request.symbol = _Symbol;
   request.volume = volumeInput;
   request.type = type;
   request.price = price;
   request.tp = tp;
   request.comment = GetCommentByGridNo(gridNo, type);
   
   if (OrderSend(request, result)) {
      Print("Create order success: Type: ", EnumToString(type), " - Ticket: ", result.order, " - Grid No: ", gridNo, " - Price: ", price, " - TP: ", tp);
   } else {
      Print("Create order failure: Type: ", EnumToString(type), " - Comment: ", result.comment, " - Grid No: ", gridNo, " - Price: ", price, " - TP: ", tp);
   }
   Sleep(1000);
}
