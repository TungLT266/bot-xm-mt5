#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#include <Trade/Trade.mqh>
#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/CommonFunction.mqh>

extern ulong magicNumberInput;

extern double priceStartGlobal;
extern bool isTakeProfitBuyGlobal;

void TakeProfitAction()
{
   if (isTakeProfitBuyGlobal)
   {
      double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if (bidPrice >= GetTP())
      {
         CloseAllPosition();
      }
   }
   else
   {
      double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if (askPrice <= GetTP())
      {
         CloseAllPosition();
      }
   }
}

void CloseAllPosition()
{
   int totalPosition = PositionsTotal();
   for (int i = totalPosition - 1; i >= 0; i--)
   {
      ulong positionTicket = PositionGetTicket(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if (magic == magicNumberInput)
      {
         ClosePosition(positionTicket);
      }
   }
}

void ClosePosition(ulong ticket)
{
   CTrade trade;
   if (trade.PositionClose(ticket))
   {
      Print("Close position success: Type: ", ticket);
   }
   else
   {
      Print("Close position failure: Type: ", ticket);
   }
}
