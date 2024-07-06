#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/trend-trading-v2/common/CommonFunction.mqh>

extern double volumeInput;
extern ulong magicNumberInput;

extern int gridAtPriceCurrentGlobal;
extern int orderGridNoUpGlobal;
extern int orderGridNoDownGlobal;
extern ENUM_ORDER_TYPE orderTypeUpGlobal;
extern ENUM_ORDER_TYPE orderTypeDownGlobal;

void CreateOrderAction()
{
   if (orderGridNoUpGlobal > 0)
   {
      if (!isExistGridNo(orderGridNoUpGlobal, orderTypeUpGlobal))
      {
         createOrder(orderGridNoUpGlobal, orderTypeUpGlobal);
      }
   }

   if (orderGridNoDownGlobal > 0)
   {
      if (!isExistGridNo(orderGridNoDownGlobal, orderTypeDownGlobal))
      {
         createOrder(orderGridNoDownGlobal, orderTypeDownGlobal);
      }
   }
}

void createOrder(int gridNo, ENUM_ORDER_TYPE type)
{
   double price = GetPriceByGridNumber(gridNo);

   double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if (price >= bidPrice && price <= askPrice)
   {
      Print("Create order failure: ", gridNo, " - Price: ", price);
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
   request.comment = GetCommentCreateOrder(gridNo, type);
   request.magic = magicNumberInput;

   if (OrderSend(request, result))
   {
      Print("Create order success: Type: ", EnumToString(type), " - Ticket: ", result.order, " - Grid No: ", gridNo, " - Price: ", price);
   }
   else
   {
      Print("Create order failure: Type: ", EnumToString(type), " - Comment: ", result.comment, " - Grid No: ", gridNo, " - Price: ", price);
   }
}

bool isExistGridNo(int gridNo, ENUM_ORDER_TYPE type)
{
   string girdNoComment = GetGridNoAndAmountByComment(GetCommentCreateOrder(gridNo, ORDER_TYPE_SELL_LIMIT));

   int totalOrder = OrdersTotal();
   for (int i = 0; i < totalOrder; i++)
   {
      ulong ticket = OrderGetTicket(i);
      ulong magic = OrderGetInteger(ORDER_MAGIC);
      if (magic == magicNumberInput)
      {
         string comment = OrderGetString(ORDER_COMMENT);
         if (GetGridNoAndAmountByComment(comment) == girdNoComment)
         {
            return true;
         }
      }
   }

   int totalPosition = PositionsTotal();
   for (int i = 0; i < totalPosition; i++)
   {
      ulong ticket = PositionGetTicket(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if (magic == magicNumberInput)
      {
         string comment = PositionGetString(POSITION_COMMENT);
         if (GetGridNoAndAmountByComment(comment) == girdNoComment)
         {
            return true;
         }
      }
   }
   return false;
}
