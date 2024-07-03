#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

extern int gridBuyTopInput;
extern int gridSellLimitInput;
extern int gridBuyLimitInput;
extern int gridSellTopInput;

extern double gridAmountInput;

extern double gridStartGlobal;

double GetPriceByGridNumber(double gridNumber) {
   return gridStartGlobal + ((gridNumber - 1) * gridAmountInput);
}

int GetTotalOrderAndPosition() {
   int totalOrder = OrdersTotal();
   int totalPosition = PositionsTotal();
   return totalOrder + totalPosition;
}

int GetStartGridBuyTop() {
   return gridSellTopInput + gridBuyLimitInput + gridSellLimitInput + 1;
}

int GetEndGridBuyTop() {
   return gridSellTopInput + gridBuyLimitInput + gridSellLimitInput + gridBuyTopInput;
}

int GetStartGridSellTop() {
   return 1;
}

int GetEndGridSellTop() {
   return gridSellTopInput;
}