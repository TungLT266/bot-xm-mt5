#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

#include <Trade/Trade.mqh>
#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/CreateValueGlobal.mqh>
#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/CommonFunction.mqh>
#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/CreateOrderAction.mqh>
#include <C:/Users/admin/AppData/Roaming/MetaQuotes/Terminal/BB16F565FAAA6B23A20C26C49416FF05/MQL5/Experts/bot-xm-mt5/bot-dca/common/TakeProfitAction.mqh>

// Input
double slAmountInput = 14000 * _Point;
int tpNumberInput = 2;
bool isTradeBuyFirstInput = true;
double volumeInput = 0.01;
ulong magicNumberInput = 666666;

// Global
double priceStartGlobal = 0;
bool isTakeProfitBuyGlobal = true;

int DELAY_SECOND = 3;

int OnInit()
{
   Print("Start bot");

   MainFuction();

   EventSetTimer(DELAY_SECOND);

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
   RefreshGlobalVariable();
   CreateOrderAction();

   RefreshGlobalVariable();
   TakeProfitAction();
}

void RefreshGlobalVariable()
{
   double priceStartNew = GetPriceStart();
   if (priceStartNew > 0 && priceStartNew != priceStartGlobal)
   {
      priceStartGlobal = priceStartNew;
      Print("Price Start: ", priceStartGlobal);
   }
   bool isTakeProfitBuyNew = GetIsTakeProfitBuy();
   if (isTakeProfitBuyGlobal != isTakeProfitBuyNew)
   {
      isTakeProfitBuyGlobal = isTakeProfitBuyNew;
      if (isTakeProfitBuyGlobal)
      {
         Print("Take profit Buy.");
      }
      else
      {
         Print("Take profit Sell.");
      }
   }
}

void OnTick() {}
