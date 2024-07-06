#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

extern int gridPointAmountInput;
extern ulong magicNumberInput;

extern int gridAtPriceCurrentGlobal;

string SEPARATOR = ".";

double GetPriceByGridNumber(int gridNo) {
   return (double) gridNo * (double) gridPointAmountInput * _Point;
}

string GetCommentCreateOrder(int gridNo, ENUM_ORDER_TYPE type) {
   string prefix;
   if (type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP) {
      prefix = "B";
   } else {
      prefix = "S";
   }
   return prefix + SEPARATOR + GetGridNoAndAmount(gridNo, type);
}

string GetGridNoAndAmountByComment(string comment) {
   return StringSubstr(comment, 2);
}

string GetGridNoAndAmount(int gridNo, ENUM_ORDER_TYPE type) {
   return StringFormat("%.0f", gridNo) + "." + StringFormat("%.0f", gridPointAmountInput);
}

int GetGridNoByComment(string comment) {
   string commentArr[];
   int size = StringSplit(comment, StringGetCharacter(SEPARATOR, 0), commentArr);
   if (size >= 2) {
      return (int) StringToInteger(commentArr[1]);
   }
   return 0;
}

bool IsExistInPosition (int gridNo) {
   int totalPosition = PositionsTotal();
   for (int i = 0; i < totalPosition; i++) {
      ulong ticket = PositionGetTicket(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if (magic == magicNumberInput) {
         if (gridNo == GetGridNoByComment(PositionGetString(POSITION_COMMENT))) {
            return true;
         }
      }
   }
   return false;
}
