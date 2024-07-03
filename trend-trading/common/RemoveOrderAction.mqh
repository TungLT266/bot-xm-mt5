#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\trend-trading\common\CommonFunction.mqh>

extern double gridAmountInput;
extern int gridTotalInput;

extern double priceStartGridGlobal;

void RemoveOrderAction() {
   double minGrid = priceStartGridGlobal - (gridAmountInput / 2);
   double maxGrid = GetPriceByGridNumber(gridTotalInput) + (gridAmountInput / 2);

   int total = OrdersTotal();
   for (int i = 0; i < total; i++) {
      ulong orderTicket = OrderGetTicket(i);
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      if (orderPrice < minGrid || orderPrice > maxGrid) {
         RemoveOrderByTicket(orderTicket);
         return;
      }
   }
}

void RemoveOrderByTicket(ulong ticket) {
   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   ZeroMemory(result);
   request.action=TRADE_ACTION_REMOVE;
   request.order = ticket;
   
   if (OrderSend(request, result)) {
      Print("Remove Order Success: Ticket: ", ticket);
   } else {
      Print("Remove Order Error: Ticket: ", ticket, " - Comment: ", result.comment);
   }
}