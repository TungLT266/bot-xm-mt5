#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/CommonFunction.mqh>

extern bool isTradeBuyFirstInput;

double GetPriceStart()
{
   if (GetTotalPosition() == 1)
   {
      int totalPosition = GetTotalPosition();
      for (int i = 0; i < totalPosition; i++)
      {
         ulong positionTicket = PositionGetTicket(i);
         ulong magic = PositionGetInteger(POSITION_MAGIC);
         if (magic == magicNumberInput)
         {
            return PositionGetDouble(POSITION_PRICE_OPEN);
         }
      }
   }
   return 0;
}

bool GetIsTakeProfitBuy()
{
   int total = GetTotalPosition();
   if (total > 0 && (total % 2 == 0))
   {
      return !isTradeBuyFirstInput;
   }
   return isTradeBuyFirstInput;
}