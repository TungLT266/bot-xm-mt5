#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

#include <Trade/Trade.mqh>
#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/CreateValueGlobal.mqh>
#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/CommonFunction.mqh>
#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/CreateOrderAction.mqh>
#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/TakeProfitAction.mqh>
#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/RemoveOrderAction.mqh>

// Input
double slAmountInput = 14000 * _Point;
bool isTradeBuyFirstInput = true;
int limitGridInput = 6;
bool isOnlyRunOnceInput = false;
int tpNumberInput = 2;
double volumeInput = 0.01;
ulong magicNumberInput = 666666;

// Global
double priceStartGlobal = 0;
bool isTakeProfitBuyGlobal = true;
bool isTradeBuyFirstGlobal;

// Constants
int DELAY_SECOND_CONSTANT = 10;
string BUY_TYPE_CONSTANT = "BUY";
string SELL_TYPE_CONSTANT = "SELL";

int OnInit()
{
   Print("Start bot");
   Print("Input: Is trade buy first: ", isTradeBuyFirstInput, " - Limit: ", limitGridInput, " - SL: ", slAmountInput, " - TP: ", tpNumberInput, " - Volume: ", volumeInput, " - Magic: ", magicNumberInput);

   isTradeBuyFirstGlobal = isTradeBuyFirstInput;

   MainFuction();

   EventSetTimer(DELAY_SECOND_CONSTANT);

   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   Print("EA đã bị gỡ bỏ, lý do: ", reason);
}

void OnTimer()
{
   MainFuction();
}

void MainFuction()
{
   if (GetTotalPosition() == 0)
   {
      RemoveOrderAction();
      if (isOnlyRunOnceInput)
      {
         Print("Stop bot.");
         ExpertRemove();
      }
   }

   RefreshGlobalVariable();
   CreateOrderAction();

   RefreshGlobalVariable();
   TakeProfitAction();
}

void RefreshGlobalVariable()
{
   SetPriceStartAndIsTradeBuyFirst();

   bool isTakeProfitBuyNew = GetIsTakeProfitBuy();
   if (isTakeProfitBuyGlobal != isTakeProfitBuyNew)
   {
      isTakeProfitBuyGlobal = isTakeProfitBuyNew;
      if (isTakeProfitBuyGlobal)
      {
         Print("Direction Up.");
      }
      else
      {
         Print("Direction Down.");
      }
   }
}

void OnTick() {}
