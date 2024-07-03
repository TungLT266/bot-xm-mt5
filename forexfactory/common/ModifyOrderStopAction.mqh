#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

extern double volumeInput;
extern double stopPriceRateInput;
extern double stopPriceSLRateInput;
extern double stopPriceTPRateInput;
extern double maxModifyPriceInput;
extern double minModifyPriceInput;
extern ulong deviationInput;

ulong orderTicket;
ENUM_ORDER_TYPE orderType;
double orderPriceOld;

void ModifyOrderStopAction(double bidPrice, double askPrice) {
   int total = OrdersTotal();
   for (int i = 0; i < total; i++) {
      orderTicket = OrderGetTicket(i);
      orderType = (ENUM_ORDER_TYPE) OrderGetInteger(ORDER_TYPE);
      orderPriceOld = OrderGetDouble(ORDER_PRICE_OPEN);
   
      ModifyStopAction(bidPrice, askPrice);
   }
}

double getNewPriceWithLimitModify(double priceNew) {
   if (priceNew > orderPriceOld) {
      double priceChange = priceNew - orderPriceOld;
      if (priceChange > maxModifyPriceInput) {
         return orderPriceOld + maxModifyPriceInput;
      }
   } else {
      double priceChange = orderPriceOld - priceNew;
      if (priceChange > maxModifyPriceInput) {
         return orderPriceOld - maxModifyPriceInput;
      }
   }
   return priceNew;
}

void ModifyStopAction(double bidPrice, double askPrice) {
   double orderPriceNew;
   double slNew;
   double tpNew;
   if (orderType == ORDER_TYPE_BUY_STOP) {
      orderPriceNew = askPrice + stopPriceRateInput;
      slNew = orderPriceNew - stopPriceSLRateInput;
      tpNew = orderPriceNew + stopPriceTPRateInput;
   } else if (orderType == ORDER_TYPE_SELL_STOP) {
      orderPriceNew = bidPrice - stopPriceRateInput;
      slNew = orderPriceNew + stopPriceSLRateInput;
      tpNew = orderPriceNew - stopPriceTPRateInput;
   } else {
      Print("Modify Order Error: Type invalid.");
      return;
   }
   
   orderPriceNew = getNewPriceWithLimitModify(orderPriceNew);
   
   if (MathAbs(orderPriceNew - orderPriceOld) < minModifyPriceInput) {
      //Print("ModifyStopAction no change price: ", orderTicket, " - Price New: ", orderPriceNew, " - Price Old:", orderPriceOld);
      return;
   }
   
   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   ZeroMemory(result);
   request.action = TRADE_ACTION_MODIFY;
   request.symbol = _Symbol;
   request.price = orderPriceNew;
   request.sl = slNew;
   request.tp = tpNew;
   request.order = orderTicket;
   request.deviation = deviationInput;
   
   if (OrderSend(request, result)) {
      Print("Modify Order Success: Type: ", EnumToString(orderType), " - Ticket: ", orderTicket, " - Price New: ", orderPriceNew,
         " - Price Old: ", orderPriceOld, " - SL New: ", slNew, " - TP New: ", tpNew);
   } else {
      Print("Modify Order Error: Type: ", EnumToString(orderType), " - Ticket: ", orderTicket, " - Comment: ", result.comment);
   }
}
