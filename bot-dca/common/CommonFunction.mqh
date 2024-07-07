#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"

extern ulong magicNumberInput;
extern bool isTradeBuyFirstInput;
extern double slAmountInput;
extern int tpNumberInput;

extern double priceStartGlobal;
extern bool isTakeProfitBuyGlobal;

int GetTotalPosition()
{
    int result = 0;
    int totalPosition = PositionsTotal();
    for (int i = 0; i < totalPosition; i++)
    {
        ulong positionTicket = PositionGetTicket(i);
        ulong magic = PositionGetInteger(POSITION_MAGIC);
        if (magic == magicNumberInput)
        {
            result++;
        }
    }
    return result;
}

double GetSL()
{
    double sl;
    if (isTradeBuyFirstInput)
    {
        if (isTakeProfitBuyGlobal)
        {
            sl = priceStartGlobal - slAmountInput;
        }
        else
        {
            sl = priceStartGlobal;
        }
    }
    else
    {
        if (isTakeProfitBuyGlobal)
        {
            sl = priceStartGlobal;
        }
        else
        {
            sl = priceStartGlobal + slAmountInput;
        }
    }
    return sl;
}

double GetTP()
{
    double tp;
    if (isTradeBuyFirstInput)
    {
        if (isTakeProfitBuyGlobal)
        {
            tp = priceStartGlobal + (slAmountInput * tpNumberInput);
        }
        else
        {
            tp = priceStartGlobal - (slAmountInput * (tpNumberInput + 1));
        }
    }
    else
    {
        if (isTakeProfitBuyGlobal)
        {
            tp = priceStartGlobal + (slAmountInput * (tpNumberInput + 1));
        }
        else
        {
            tp = priceStartGlobal - (slAmountInput * tpNumberInput);
        }
    }
    return tp;
}
