#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/trend-trading-v2/common/CommonFunction.mqh>

extern ulong magicNumberInput;

extern int gridAtPriceCurrentGlobal;
extern int orderGridNoUpGlobal;
extern int orderGridNoDownGlobal;
extern ENUM_ORDER_TYPE orderTypeUpGlobal;
extern ENUM_ORDER_TYPE orderTypeDownGlobal;

void RemoveOrderAction()
{
   ulong ticketArr[];

   string commentUp = GetCommentCreateOrder(orderGridNoUpGlobal, orderTypeUpGlobal);
   string commentDown = GetCommentCreateOrder(orderGridNoDownGlobal, orderTypeDownGlobal);

   int count = 0;
   int total = OrdersTotal();
   for (int i = 0; i < total; i++)
   {
      ulong ticket = OrderGetTicket(i);
      ulong magic = OrderGetInteger(ORDER_MAGIC);
      if (magic == magicNumberInput)
      {
         string comment = OrderGetString(ORDER_COMMENT);
         if (comment != commentUp && comment != commentDown)
         {
            Print("Remove order: ", comment, " - Up: ", commentUp, " - Down: ", commentDown);
            ArrayResize(ticketArr, count + 1);
            ticketArr[count] = ticket;
            count++;
         }
      }
   }

   if (ArraySize(ticketArr) > 0)
   {
      for (int i = 0; i < count; i++)
      {
         RemoveOrderByTicket(ticketArr[i]);
      }
   }
}

void RemoveOrderAll()
{
   int total = OrdersTotal();
   for (int i = 0; i < total; i++)
   {
      ulong orderTicket = OrderGetTicket(0);
      RemoveOrderByTicket(orderTicket);
   }
}

void RemoveOrderByTicket(ulong ticket)
{
   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   ZeroMemory(result);
   request.action = TRADE_ACTION_REMOVE;
   request.order = ticket;

   if (OrderSend(request, result))
   {
      Print("Remove Order Success: Ticket: ", ticket);
   }
   else
   {
      Print("Remove Order Error: Ticket: ", ticket, " - Comment: ", result.comment);
   }
}