#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"

extern ulong magicNumberInput;
extern double slAmountInput;
extern int tpNumberInput;

extern double priceStartGlobal;
extern bool isTakeProfitBuyGlobal;
extern bool isTradeBuyFirstGlobal;

extern string BUY_TYPE_CONSTANT;
extern string SELL_TYPE_CONSTANT;

double GetPriceByTypeOrder(string type)
{
    if (type == BUY_TYPE_CONSTANT)
    {
        if (isTradeBuyFirstGlobal)
        {
            return priceStartGlobal;
        }
        else
        {
            return priceStartGlobal + slAmountInput;
        }
    }
    else
    {
        if (isTradeBuyFirstGlobal)
        {
            return priceStartGlobal - slAmountInput;
        }
        else
        {
            return priceStartGlobal;
        }
    }
}

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

int GetTotalOrder()
{
    int result = 0;
    int totalOrder = OrdersTotal();
    for (int i = 0; i < totalOrder; i++)
    {
        ulong ticket = OrderGetTicket(i);
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
    if (isTradeBuyFirstGlobal)
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
    if (isTradeBuyFirstGlobal)
    {
        if (GetTotalPosition() == 1)
        {
            return priceStartGlobal + slAmountInput;
        }
        else if (isTakeProfitBuyGlobal)
        {
            return priceStartGlobal + (slAmountInput * tpNumberInput);
        }
        return priceStartGlobal - (slAmountInput * (tpNumberInput + 1));
    }
    else
    {
        if (GetTotalPosition() == 1)
        {
            return priceStartGlobal - slAmountInput;
        }
        else if (isTakeProfitBuyGlobal)
        {
            return priceStartGlobal + (slAmountInput * (tpNumberInput + 1));
        }
        return priceStartGlobal - (slAmountInput * tpNumberInput);
    }
}
