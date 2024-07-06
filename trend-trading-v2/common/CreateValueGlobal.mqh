#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#include <C:\Users\admin\AppData\Roaming\MetaQuotes\Terminal\BB16F565FAAA6B23A20C26C49416FF05\MQL5\Experts\bot-xm-mt5\trend-trading-v2\common\CommonFunction.mqh>

extern int gridAtPriceCurrentGlobal;
extern int differenceBuyAndSellPositionGlobal;

int GetOrderGridNoUp()
{
   for (int i = gridAtPriceCurrentGlobal + 1; i < gridAtPriceCurrentGlobal + 6; i++)
   {
      if (!IsExistInPosition(i))
      {
         return i;
      }
   }
   return 0;
}

int GetOrderGridNoDown()
{
   for (int i = gridAtPriceCurrentGlobal; i > gridAtPriceCurrentGlobal - 5; i--)
   {
      if (!IsExistInPosition(i))
      {
         return i;
      }
   }
   return 0;
}

ENUM_ORDER_TYPE GetOrderTypeUp()
{
   if (differenceBuyAndSellPositionGlobal < 0)
   {
      return ORDER_TYPE_BUY_STOP;
   }
   return ORDER_TYPE_SELL_LIMIT;
}

ENUM_ORDER_TYPE GetOrderTypeDown()
{
   if (differenceBuyAndSellPositionGlobal > 0)
   {
      return ORDER_TYPE_SELL_STOP;
   }
   return ORDER_TYPE_BUY_LIMIT;
}

int GetDifferenceBuyAndSellPosition()
{
   int totalPosition = PositionsTotal();
   if (totalPosition > 0)
   {
      int totalPositionBuy = GetTotalPositionBuy();
      int totalPositionSell = GetTotalPositionSell();
      return totalPositionBuy - totalPositionSell;
   }
   return 0;
}

int GetTotalPositionBuy()
{
   int result = 0;
   int totalPosition = PositionsTotal();
   for (int i = 0; i < totalPosition; i++)
   {
      ulong positionTicket = PositionGetTicket(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if (magic == magicNumberInput)
      {
         ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if (positionType == POSITION_TYPE_BUY)
         {
            result++;
         }
      }
   }
   return result;
}

int GetTotalPositionSell()
{
   int result = 0;
   int totalPosition = PositionsTotal();
   for (int i = 0; i < totalPosition; i++)
   {
      ulong positionTicket = PositionGetTicket(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if (magic == magicNumberInput)
      {
         ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if (positionType == POSITION_TYPE_SELL)
         {
            result++;
         }
      }
   }
   return result;
}
