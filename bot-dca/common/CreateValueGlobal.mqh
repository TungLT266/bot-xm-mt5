#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/CommonFunction.mqh>

extern bool isTradeBuyFirstGlobal;

double GetPriceStart()
{
   int totalPosition = GetTotalPosition();
   for (int i = 0; i < totalPosition; i++)
   {
      ulong positionTicket = PositionGetTicket(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if (magic == magicNumberInput)
      {
         string comment = PositionGetString(POSITION_COMMENT);
         if (StringToInteger(comment) == 1)
         {
            return PositionGetDouble(POSITION_PRICE_OPEN);
         }
      }
   }
   return 0;
}

bool GetIsTakeProfitBuy()
{
   ENUM_POSITION_TYPE typeToTakeProfit = POSITION_TYPE_BUY;
   int gridNoTakeProfit = 0;

   int totalPosition = PositionsTotal();
   for (int i = 0; i < totalPosition; i++)
   {
      ulong positionTicket = PositionGetTicket(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if (magic == magicNumberInput)
      {
         string comment = PositionGetString(POSITION_COMMENT);
         int gridNoComment = (int)StringToInteger(comment);
         if (gridNoComment > gridNoTakeProfit)
         {
            gridNoTakeProfit = gridNoComment;
            typeToTakeProfit = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         }
      }
   }
   if (gridNoTakeProfit > 0)
   {
      return typeToTakeProfit == POSITION_TYPE_BUY;
   }
   return isTradeBuyFirstGlobal;
}