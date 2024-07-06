#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\trend-trading-v2\common\CommonFunction.mqh>

extern int differenceBuyAndSellPositionGlobal;

void ModifyOrderTPAction() {
   
   if (differenceBuyAndSellPositionGlobal > 0) {
      ClearTP(POSITION_TYPE_SELL);
   } else if (differenceBuyAndSellPositionGlobal < 0) {
      ClearTP(POSITION_TYPE_BUY);
   }
}

void ClearTP(ENUM_POSITION_TYPE clearType) {
   int totalPosition = PositionsTotal();
   for (int i = 0; i < totalPosition; i++) {
      ulong positionTicket = PositionGetTicket(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if (magic == magicNumberInput) {
         ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
         if (positionType == clearType) {
            ModifyPositionTP(positionTicket, 0);
         }
      }
   }
}

void ModifyPositionTP(ulong ticket, double tp) {
   if (!PositionSelectByTicket(ticket)) {
      Print("Modify Position TP failure: ", ticket);
      return;
   }
   
   if (tp == PositionGetDouble(POSITION_TP)) {
      return;
   }
   
   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   ZeroMemory(result);
   request.action = TRADE_ACTION_SLTP;
   request.position = ticket;
   request.symbol = _Symbol;
   request.tp = tp;
   
   if (OrderSend(request, result)) {
      Print("Modify Position TP success: Ticket: ", ticket, " - TP: ", tp);
   } else {
      Print("Modify Position TP failure: Ticket: ", ticket, " - TP: ", tp, " - Comment: ", result.comment);
   }
}
