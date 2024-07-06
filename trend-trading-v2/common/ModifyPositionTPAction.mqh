#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"

#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/trend-trading-v2/common/CommonFunction.mqh>

extern int gridPointAmountInput;

extern int differenceBuyAndSellPositionGlobal;

void ModifyPositionTPAction()
{
   ulong positionBuyLowestTicket = 0;
   ulong positionSellHighestTicket = 0;

   int gridNoBuyLowestTicket = 0;
   int gridNoSellHighestTicket = 0;

   int totalPosition = PositionsTotal();
   for (int i = 0; i < totalPosition; i++)
   {
      ulong positionTicket = PositionGetTicket(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if (magic == magicNumberInput)
      {
         ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         string comment = PositionGetString(POSITION_COMMENT);
         int gridNo = GetGridNoByComment(comment);
         if (positionType == POSITION_TYPE_BUY)
         {
            if (positionBuyLowestTicket == 0)
            {
               positionBuyLowestTicket = positionTicket;
               gridNoBuyLowestTicket = gridNo;
            }
            else if (gridNoBuyLowestTicket > gridNo)
            {
               positionBuyLowestTicket = positionTicket;
               gridNoBuyLowestTicket = gridNo;
            }
         }
         else
         {
            if (positionSellHighestTicket == 0)
            {
               positionSellHighestTicket = positionTicket;
               gridNoSellHighestTicket = gridNo;
            }
            else if (gridNoSellHighestTicket < gridNo)
            {
               positionSellHighestTicket = positionTicket;
               gridNoSellHighestTicket = gridNo;
            }
         }
      }
   }

   if (differenceBuyAndSellPositionGlobal > 0)
   {
      positionSellHighestTicket = 0;
   }
   else if (differenceBuyAndSellPositionGlobal < 0)
   {
      positionBuyLowestTicket = 0;
   }
   ClearTP(positionBuyLowestTicket, positionSellHighestTicket);
}

void ClearTP(ulong positionBuyLowestTicket, ulong positionSellHighestTicket)
{
   int totalPosition = PositionsTotal();
   for (int i = 0; i < totalPosition; i++)
   {
      ulong positionTicket = PositionGetTicket(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if (magic == magicNumberInput)
      {
         double price = PositionGetDouble(POSITION_PRICE_OPEN);
         double tpNew = 0;
         if (positionTicket == positionBuyLowestTicket)
         {
            tpNew = price + gridPointAmountInput;
         }
         else if (positionTicket == positionSellHighestTicket)
         {
            tpNew = price - gridPointAmountInput;
         }
         if (tpNew != PositionGetDouble(POSITION_TP))
         {
            ModifyPositionTP(positionTicket, tpNew, (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE));
         }
      }
   }
}

void ClosePosition(ulong ticket)
{
   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   ZeroMemory(result);
   request.action = TRADE_ACTION_CLOSE_BY;
   request.position = ticket;
   request.position_by = PositionGetInteger(POSITION_TICKET);
   request.magic = magicNumberInput;

   if (OrderSend(request, result))
   {
      Print("Close Position success: Ticket: ", ticket);
   }
   else
   {
      Print("Close Position failure: Ticket: ", ticket, " - Comment: ", result.comment);
   }
}

void ModifyPositionTP(ulong ticket, double tpNew, ENUM_POSITION_TYPE positionType)
{
   if (positionType == POSITION_TYPE_BUY)
   {
      if (tpNew <= SymbolInfoDouble(_Symbol, SYMBOL_BID))
      {
         ClosePosition(ticket);
         return;
      }
   }
   else
   {
      if (tpNew >= SymbolInfoDouble(_Symbol, SYMBOL_ASK))
      {
         ClosePosition(ticket);
         return;
      }
   }

   MqlTradeRequest request;
   MqlTradeResult result;

   ZeroMemory(request);
   ZeroMemory(result);
   request.action = TRADE_ACTION_SLTP;
   request.position = ticket;
   request.symbol = _Symbol;
   request.tp = tpNew;

   if (OrderSend(request, result))
   {
      Print("Modify Position TP success: Ticket: ", ticket, " - TP: ", tpNew);
   }
   else
   {
      Print("Modify Position TP failure: Ticket: ", ticket, " - TP: ", tpNew, " - Comment: ", result.comment);
   }
}
