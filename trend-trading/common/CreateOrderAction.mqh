#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\trend-trading\common\CommonFunction.mqh>

extern int gridTotalInput;
extern double volumeInput;
extern double gridAmountInput;

void CreateOrderAction() {
   for (int i = 1; i <= gridTotalInput; i++) {
      createOrder(i);
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

void createOrder(int gridNumber) {
   if (isExistGridNumber(gridNumber)) {
      return;
   }

   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double price = GetPriceByGridNumber(gridNumber);
   double tp;
   ENUM_ORDER_TYPE type;
   
   if (price < bidPrice) {
      tp = price - gridAmountInput;
      type = ORDER_TYPE_SELL_STOP;
   } else if (price > askPrice) {
      tp = price + gridAmountInput;
      type = ORDER_TYPE_BUY_STOP;
   } else {
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
   request.comment = "Grid No." + IntegerToString(gridNumber);
   
   if (OrderSend(request, result)) {
      Print("Create order success: Type: ", EnumToString(type), " - Ticket: ", result.order, " - Grid Number: ", gridNumber, " - Price: ", price, " - TP: ", tp);
   } else {
      Print("Create order failure: Type: ", EnumToString(type), " - Comment: ", result.comment, " - Grid Number: ", gridNumber, " - Price: ", price, " - TP: ", tp);
   }
   Sleep(1000);
}
