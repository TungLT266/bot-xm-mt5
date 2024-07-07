#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/CommonFunction.mqh>

extern ulong magicNumberInput;
extern bool isTradeBuyFirstInput;
extern double slAmountInput;
extern double volumeInput;

extern double priceStartGlobal;
extern bool isTakeProfitBuyGlobal;

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

void CreateOrderFirst()
{
   ENUM_ORDER_TYPE orderType;
   if (isTradeBuyFirstInput)
   {
      orderType = ORDER_TYPE_BUY;
   }
   else
   {
      orderType = ORDER_TYPE_SELL;
   }
   CreateOrder(1, orderType);
}

void CreateOrderAfterFirst()
{
   if (isTakeProfitBuyGlobal)
   {
      double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if (bidPrice <= GetSL())
      {
         CreateOrder(GetTotalPosition() + 1, ORDER_TYPE_SELL);
      }
   }
   else
   {
      double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if (askPrice >= GetSL())
      {
         CreateOrder(GetTotalPosition() + 1, ORDER_TYPE_BUY);
      }
   }
}

void CreateOrder(int gridNo, ENUM_ORDER_TYPE type)
{
   double volume = GetVolumeByGridNo(gridNo);

   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = volume;
   request.type = type;
   request.comment = IntegerToString(gridNo);
   request.magic = magicNumberInput;

   if (OrderSend(request, result))
   {
      Print("Create order success: Type: ", EnumToString(type), " - Ticket: ", result.order, " - No: ", gridNo);
   }
   else
   {
      Print("Create order failure: Type: ", EnumToString(type), " - Comment: ", result.comment, " - No: ", gridNo);
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
