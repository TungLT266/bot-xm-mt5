#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/CommonFunction.mqh>

extern ulong magicNumberInput;
extern double slAmountInput;
extern double volumeInput;
extern int limitGridInput;

extern double priceStartGlobal;
extern bool isTakeProfitBuyGlobal;
extern bool isTradeBuyFirstGlobal;

extern string BUY_TYPE_CONSTANT;
extern string SELL_TYPE_CONSTANT;

void CreateOrderAction()
{
   int totalPosition = GetTotalPosition();
   if (totalPosition == 0)
   {
      CreateOrderFirst();
      return;
   }
   CreateOrderAfterFirst();
}

void CreateOrderAfterFirst()
{
   int totalPosition = GetTotalPosition();
   if (totalPosition > 0 && totalPosition < limitGridInput)
   {
      int totalOrder = GetTotalOrder();
      if (totalOrder == 0)
      {
         if (isTakeProfitBuyGlobal)
         {
            CreateOrder(GetTotalPosition() + 1, SELL_TYPE_CONSTANT);
         }
         else
         {
            CreateOrder(GetTotalPosition() + 1, BUY_TYPE_CONSTANT);
         }
      }
   }
}

void CreateOrderFirst()
{
   ENUM_ORDER_TYPE orderType;
   if (isTradeBuyFirstGlobal)
   {
      orderType = ORDER_TYPE_BUY;
   }
   else
   {
      orderType = ORDER_TYPE_SELL;
   }

   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = volumeInput;
   request.type = orderType;
   request.comment = "1";
   request.magic = magicNumberInput;

   if (OrderSend(request, result))
   {
      Print("Create order success: Type: ", EnumToString(orderType), " - Ticket: ", result.order, " - No: 1");
   }
   else
   {
      Print("Create order failure: Type: ", EnumToString(orderType), " - Comment: ", result.comment, " - No: 1");
   }
}

void CreateOrder(int gridNo, string type)
{
   double volume = GetVolumeByGridNo(gridNo);
   ENUM_ORDER_TYPE orderType;
   if (type == BUY_TYPE_CONSTANT)
   {
      orderType = ORDER_TYPE_BUY_STOP;
   }
   else
   {
      orderType = ORDER_TYPE_SELL_STOP;
   }

   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   request.action = TRADE_ACTION_PENDING;
   request.symbol = _Symbol;
   request.volume = volume;
   request.type = orderType;
   request.price = GetPriceByTypeOrder(type);
   request.comment = IntegerToString(gridNo);
   request.magic = magicNumberInput;

   if (OrderSend(request, result))
   {
      Print("Create order success: Type: ", EnumToString(orderType), " - Ticket: ", result.order, " - No: 1");
   }
   else
   {
      Print("Create order failure: Type: ", EnumToString(orderType), " - Comment: ", result.comment, " - No: 1");
   }
}

double GetVolumeByGridNo(int gridNo)
{
   if (gridNo == 1)
   {
      return volumeInput;
   }
   else if (gridNo == 2)
   {
      return volumeInput * 2;
   }

   double gridNoMinus1Volume = 0;
   double gridNoMinus2Volume = 0;

   int totalPosition = PositionsTotal();
   for (int i = 0; i < totalPosition; i++)
   {
      ulong positionTicket = PositionGetTicket(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if (magic == magicNumberInput)
      {
         string comment = PositionGetString(POSITION_COMMENT);
         int gridNoComment = (int)StringToInteger(comment);
         if (gridNoComment == (gridNo - 1))
         {
            gridNoMinus1Volume = PositionGetDouble(POSITION_VOLUME);
         }
         else if (gridNoComment == (gridNo - 2))
         {
            gridNoMinus2Volume = PositionGetDouble(POSITION_VOLUME);
         }
      }
   }
   return gridNoMinus1Volume + gridNoMinus2Volume;
}
