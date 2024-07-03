#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

extern double stopPriceSLRateInput;

ulong positionTicket;
ENUM_POSITION_TYPE positionType;
double tpOld;
double slOld;
double positionPrice;

void ModifyPositionSLAction(double bidPrice, double askPrice) {
   int total = PositionsTotal();
   for (int i = 0; i < total; i++) {
      positionTicket = PositionGetTicket(i);
      positionType = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
      tpOld = PositionGetDouble(POSITION_TP);
      slOld = PositionGetDouble(POSITION_SL);
      positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      
      ModifyPositionSL(bidPrice, askPrice);
   }
}

double GetSLNewForBuy(double bidPrice) {
   if (bidPrice >= (positionPrice + (stopPriceSLRateInput * 3))) {
      if (slOld < (positionPrice + stopPriceSLRateInput)) {
         return positionPrice + stopPriceSLRateInput;
      }
   } else if (bidPrice >= (positionPrice + stopPriceSLRateInput)) {
      if (slOld < positionPrice) {
         return positionPrice;
      }
   } else if (bidPrice >= positionPrice) {
      if (slOld < (positionPrice - stopPriceSLRateInput)) {
         return positionPrice - stopPriceSLRateInput;
      }
   }
   return slOld;
}

double GetSLNewForSell(double askPrice) {
   if (askPrice <= (positionPrice - (stopPriceSLRateInput * 3))) {
      if (slOld > (positionPrice - stopPriceSLRateInput)) {
         return positionPrice - stopPriceSLRateInput;
      }
   } else if (askPrice <= (positionPrice - stopPriceSLRateInput)) {
      if (slOld > positionPrice) {
         return positionPrice;
      }
   } else if (askPrice <= positionPrice) {
      if (slOld > (positionPrice + stopPriceSLRateInput)) {
         return positionPrice + stopPriceSLRateInput;
      }
   }
   return slOld;
}

void ModifyPositionSL(double bidPrice, double askPrice) {
   double slNew = slOld;
   if (positionType == POSITION_TYPE_BUY) {
      slNew = GetSLNewForBuy(bidPrice);
   } else if (positionType == POSITION_TYPE_SELL) {
      slNew = GetSLNewForSell(askPrice);
   }
   
   if (slNew == slOld) {
      return;
   }
   
   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   ZeroMemory(result);
   request.action = TRADE_ACTION_SLTP;
   request.position = positionTicket;
   request.symbol = _Symbol;
   request.sl = slNew;
   request.tp = tpOld;
   
   if (OrderSend(request, result)) {
      Print("Modify SL Success: Type: ", EnumToString(positionType), " - Ticket: ", positionTicket, " - SL New: ", slNew, " - SL Old: ", slOld);
   } else {
      Print("Modify SL Error: Type: ", EnumToString(positionType), " - Ticket: ", positionTicket, " - Comment: ", result.comment);
   }
}
