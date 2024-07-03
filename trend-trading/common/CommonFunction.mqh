#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

extern double gridAmountInput;
extern int gridTotalInput;

extern double priceStartGridGlobal;

double GetPriceByGridNumber(double gridNumber) {
   return priceStartGridGlobal + ((gridNumber - 1) * gridAmountInput);
}

double GetPriceStartGrid(double bidPrice) {
   double startGridNumber = MathFloor(bidPrice / gridAmountInput) + 1 - (gridTotalInput / 2);
   return startGridNumber * gridAmountInput;
}
