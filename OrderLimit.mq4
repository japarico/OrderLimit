//+------------------------------------------------------------------+
//|                                                Order Manager EA.mq4 |
//|                                         Copyright 2025, japarico |
//+------------------------------------------------------------------+
#import "user32.dll"
int MessageBoxA(int Ignore,string Caption,string Title,int Icon);
#import

#property strict

input double lotSize=0.01;//Lot Size
input int ftp=1000;//Fake Take Profit
input int fsl=1000;//Fake Stop Loss
input int ttp=150;//True Take Profit
input int tsl=100;//True Stop Loss
input int lip=100;//Lock In Points
input int alip=120;//Activate Lock In Points after X Points in Profit
input bool buttons=true;//Use Buttons
input int xoff=150;//Buttons X Offset
input int yoff=100;//Buttons Y Offset
input int gmt=3;//GMT Offset
input bool DrawLines=false;//Draw Alert Lines
input string prefix="";//Symbol Prefix
input string suffix="";//Symbol Suffix

input bool Alerts=true;
input double InpMaxLossPercent=5.0; //Default Max Account Loss (%)

datetime curtime,prevtime;
int dig=1;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   if(buttons)
     {
      //Lot Size Selector
      ObjectCreate(0,"LotMinus",OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,"LotMinus",OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,"LotMinus",OBJPROP_BGCOLOR,clrGray);
      ObjectSet("LotMinus",OBJPROP_CORNER,3);
      ObjectSet("LotMinus",OBJPROP_XDISTANCE,xoff-15);
      ObjectSet("LotMinus",OBJPROP_YDISTANCE,yoff+45);
      ObjectSetInteger(0,"LotMinus",OBJPROP_XSIZE,25);
      ObjectSetInteger(0,"LotMinus",OBJPROP_YSIZE,20);
      ObjectSetInteger(0,"LotMinus",OBJPROP_STATE,0);
      ObjectSetString(0,"LotMinus",OBJPROP_FONT,"Arial");
      ObjectSetString(0,"LotMinus",OBJPROP_TEXT,"-");
      ObjectSetInteger(0,"LotMinus",OBJPROP_FONTSIZE,10);
      ObjectSetInteger(0,"LotMinus",OBJPROP_SELECTABLE,0);

      ObjectCreate(0,"LotSize",OBJ_EDIT,0,0,0);
      ObjectSetInteger(0,"LotSize",OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,"LotSize",OBJPROP_BGCOLOR,clrWhite);
      ObjectSet("LotSize",OBJPROP_CORNER,3);
      ObjectSet("LotSize",OBJPROP_XDISTANCE,xoff-40);
      ObjectSet("LotSize",OBJPROP_YDISTANCE,yoff+45);
      ObjectSetInteger(0,"LotSize",OBJPROP_XSIZE,50);
      ObjectSetInteger(0,"LotSize",OBJPROP_YSIZE,20);
      ObjectSetString(0,"LotSize",OBJPROP_FONT,"Arial");
      ObjectSetString(0,"LotSize",OBJPROP_TEXT,DoubleToStr(lotSize,2));
      ObjectSetInteger(0,"LotSize",OBJPROP_FONTSIZE,10);
      ObjectSetInteger(0,"LotSize",OBJPROP_READONLY,false);

      ObjectCreate(0,"LotPlus",OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,"LotPlus",OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,"LotPlus",OBJPROP_BGCOLOR,clrGray);
      ObjectSet("LotPlus",OBJPROP_CORNER,3);
      ObjectSet("LotPlus",OBJPROP_XDISTANCE,xoff-80);
      ObjectSet("LotPlus",OBJPROP_YDISTANCE,yoff+45);
      ObjectSetInteger(0,"LotPlus",OBJPROP_XSIZE,25);
      ObjectSetInteger(0,"LotPlus",OBJPROP_YSIZE,20);
      ObjectSetInteger(0,"LotPlus",OBJPROP_STATE,0);
      ObjectSetString(0,"LotPlus",OBJPROP_FONT,"Arial");
      ObjectSetString(0,"LotPlus",OBJPROP_TEXT,"+");
      ObjectSetInteger(0,"LotPlus",OBJPROP_FONTSIZE,10);
      ObjectSetInteger(0,"LotPlus",OBJPROP_SELECTABLE,0);

      //--- NEW PANEL CONTROLS: Max Loss % Selector ---
      ObjectCreate(0,"MaxLossLabel",OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,"MaxLossLabel",OBJPROP_COLOR,clrWhite);
      ObjectSet("MaxLossLabel",OBJPROP_CORNER,3);
      ObjectSet("MaxLossLabel",OBJPROP_XDISTANCE,xoff+40);
      ObjectSet("MaxLossLabel",OBJPROP_YDISTANCE,yoff+70);
      ObjectSetString(0,"MaxLossLabel",OBJPROP_FONT,"Arial");
      ObjectSetString(0,"MaxLossLabel",OBJPROP_TEXT,"Max Loss %:");
      ObjectSetInteger(0,"MaxLossLabel",OBJPROP_FONTSIZE,9);

      ObjectCreate(0,"MaxLossSize",OBJ_EDIT,0,0,0);
      ObjectSetInteger(0,"MaxLossSize",OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,"MaxLossSize",OBJPROP_BGCOLOR,clrWhite);
      ObjectSet("MaxLossSize",OBJPROP_CORNER,3);
      ObjectSet("MaxLossSize",OBJPROP_XDISTANCE,xoff-40);
      ObjectSet("MaxLossSize",OBJPROP_YDISTANCE,yoff+68);
      ObjectSetInteger(0,"MaxLossSize",OBJPROP_XSIZE,50);
      ObjectSetInteger(0,"MaxLossSize",OBJPROP_YSIZE,20);
      ObjectSetString(0,"MaxLossSize",OBJPROP_FONT,"Arial");
      ObjectSetString(0,"MaxLossSize",OBJPROP_TEXT,DoubleToStr(InpMaxLossPercent,1));
      ObjectSetInteger(0,"MaxLossSize",OBJPROP_FONTSIZE,10);
      ObjectSetInteger(0,"MaxLossSize",OBJPROP_READONLY,false);
      //-----------------------------------------------

      //Buys
      ObjectCreate(0,"BuyMarket",OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,"BuyMarket",OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,"BuyMarket",OBJPROP_BGCOLOR,clrLime);
      ObjectSet("BuyMarket",OBJPROP_CORNER,3);
      ObjectSet("BuyMarket",OBJPROP_XDISTANCE,xoff);
      ObjectSet("BuyMarket",OBJPROP_YDISTANCE,yoff);
      ObjectSetInteger(0,"BuyMarket",OBJPROP_XSIZE,50);
      ObjectSetInteger(0,"BuyMarket",OBJPROP_YSIZE,15);
      ObjectSetInteger(0,"BuyMarket",OBJPROP_STATE,0);
      ObjectSetString(0,"BuyMarket",OBJPROP_FONT,"Arial");
      ObjectSetString(0,"BuyMarket",OBJPROP_TEXT,"Buy");
      ObjectSetInteger(0,"BuyMarket",OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,"BuyMarket",OBJPROP_SELECTABLE,0);

      //Sells
      ObjectCreate(0,"SellMarket",OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,"SellMarket",OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,"SellMarket",OBJPROP_BGCOLOR,clrRed);
      ObjectSet("SellMarket",OBJPROP_CORNER,3);
      ObjectSet("SellMarket",OBJPROP_XDISTANCE,xoff);
      ObjectSet("SellMarket",OBJPROP_YDISTANCE,yoff-20);
      ObjectSetInteger(0,"SellMarket",OBJPROP_XSIZE,50);
      ObjectSetInteger(0,"SellMarket",OBJPROP_YSIZE,15);
      ObjectSetInteger(0,"SellMarket",OBJPROP_STATE,0);
      ObjectSetString(0,"SellMarket",OBJPROP_FONT,"Arial");
      ObjectSetString(0,"SellMarket",OBJPROP_TEXT,"Sell");
      ObjectSetInteger(0,"SellMarket",OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,"SellMarket",OBJPROP_SELECTABLE,0);

      ObjectCreate(0,"CloseP",OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,"CloseP",OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,"CloseP",OBJPROP_BGCOLOR,clrOrange);
      ObjectSet("CloseP",OBJPROP_CORNER,3);
      ObjectSet("CloseP",OBJPROP_XDISTANCE,xoff);
      ObjectSet("CloseP",OBJPROP_YDISTANCE,yoff+20);
      ObjectSetInteger(0,"CloseP",OBJPROP_XSIZE,125);
      ObjectSetInteger(0,"CloseP",OBJPROP_YSIZE,15);
      ObjectSetInteger(0,"CloseP",OBJPROP_STATE,0);
      ObjectSetString(0,"CloseP",OBJPROP_FONT,"Arial");
      ObjectSetString(0,"CloseP",OBJPROP_TEXT,"Close Profit");
      ObjectSetInteger(0,"CloseP",OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,"CloseP",OBJPROP_SELECTABLE,0);

      ObjectCreate(0,"SetBE",OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,"SetBE",OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,"SetBE",OBJPROP_BGCOLOR,clrDodgerBlue);
      ObjectSet("SetBE",OBJPROP_CORNER,3);
      ObjectSet("SetBE",OBJPROP_XDISTANCE,xoff);
      ObjectSet("SetBE",OBJPROP_YDISTANCE,yoff-60);
      ObjectSetInteger(0,"SetBE",OBJPROP_XSIZE,125);
      ObjectSetInteger(0,"SetBE",OBJPROP_YSIZE,15);
      ObjectSetInteger(0,"SetBE",OBJPROP_STATE,0);
      ObjectSetString(0,"SetBE",OBJPROP_FONT,"Arial");
      ObjectSetString(0,"SetBE",OBJPROP_TEXT,"Set to Break Even");
      ObjectSetInteger(0,"SetBE",OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,"SetBE",OBJPROP_SELECTABLE,0);

      ObjectCreate(0,"CloseA",OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,"CloseA",OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,"CloseA",OBJPROP_BGCOLOR,clrOrange);
      ObjectSet("CloseA",OBJPROP_CORNER,3);
      ObjectSet("CloseA",OBJPROP_XDISTANCE,xoff);
      ObjectSet("CloseA",OBJPROP_YDISTANCE,yoff-40);
      ObjectSetInteger(0,"CloseA",OBJPROP_XSIZE,125);
      ObjectSetInteger(0,"CloseA",OBJPROP_YSIZE,15);
      ObjectSetInteger(0,"CloseA",OBJPROP_STATE,0);
      ObjectSetString(0,"CloseA",OBJPROP_FONT,"Arial");
      ObjectSetString(0,"CloseA",OBJPROP_TEXT,"Close All");
      ObjectSetInteger(0,"CloseA",OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,"CloseA",OBJPROP_SELECTABLE,0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete(0,"LotMinus");
   ObjectDelete(0,"LotSize");
   ObjectDelete(0,"LotPlus");
   ObjectDelete(0,"MaxLossLabel");
   ObjectDelete(0,"MaxLossSize");
   ObjectDelete(0,"BuyMarket");
   ObjectDelete(0,"SellMarket");
   ObjectDelete(0,"CloseP");
   ObjectDelete(0,"CloseA");
   ObjectDelete(0,"SetBE");
   return(0);
  }

//+------------------------------------------------------------------+
//| Modern MT4 UI Event Handler Engine                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      // --- BUY BUTTON ---
      if(sparam == "BuyMarket")
        {
         double currentLotSize = StringToDouble(ObjectGetString(0,"LotSize",OBJPROP_TEXT));
         RefreshRates();
         if(OrderSend(Symbol(),OP_BUY,currentLotSize,Ask,3,0,0,NULL,0,0,0) < 0)
            Print("OrderSend Buy Error: ",GetLastError());

         ObjectSetInteger(0,"BuyMarket",OBJPROP_STATE,0);
         ChartRedraw();
        }

      // --- SELL BUTTON ---
      if(sparam == "SellMarket")
        {
         double currentLotSize = StringToDouble(ObjectGetString(0,"LotSize",OBJPROP_TEXT));
         RefreshRates();
         if(OrderSend(Symbol(),OP_SELL,currentLotSize,Bid,3,0,0,NULL,0,0,0) < 0)
            Print("OrderSend Sell Error: ",GetLastError());

         ObjectSetInteger(0,"SellMarket",OBJPROP_STATE,0);
         ChartRedraw();
        }

      // --- LOT MINUS ---
      if(sparam == "LotMinus")
        {
         double currentLot = StringToDouble(ObjectGetString(0,"LotSize",OBJPROP_TEXT));
         currentLot = MathMax(0.01, currentLot - 0.01);
         ObjectSetString(0,"LotSize",OBJPROP_TEXT,DoubleToStr(currentLot,2));
         ObjectSetInteger(0,"LotMinus",OBJPROP_STATE,0);
         ChartRedraw();
        }

      // --- LOT PLUS ---
      if(sparam == "LotPlus")
        {
         double currentLot = StringToDouble(ObjectGetString(0,"LotSize",OBJPROP_TEXT));
         currentLot = currentLot + 0.01;
         ObjectSetString(0,"LotSize",OBJPROP_TEXT,DoubleToStr(currentLot,2));
         ObjectSetInteger(0,"LotPlus",OBJPROP_STATE,0);
         ChartRedraw();
        }

      // --- CLOSE PROFIT ---
      if(sparam == "CloseP")
        {
         for(int i=OrdersTotal()-1;i>=0;i--)
           {
            if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
            if(OrderSymbol()!=Symbol()) continue;
            if(OrderProfit()+OrderSwap()+OrderCommission()>=0)
              {
               RefreshRates();
               double closePrice = (OrderType() == OP_BUY) ? Bid : Ask;
               if(!OrderClose(OrderTicket(),OrderLots(),closePrice,3,clrNONE))
                  Print("OrderClose Error: ",GetLastError());
              }
           }
         ObjectSetInteger(0,"CloseP",OBJPROP_STATE,0);
         ChartRedraw();
        }

      // --- SET BREAK EVEN ---
      if(sparam == "SetBE")
        {
         datetime last_open_time = 0;
         double last_open_price = 0;
         int last_order_ticket = -1;

         for(int i=OrdersTotal()-1; i>=0; i--)
           {
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
              {
               if(OrderOpenTime() > last_open_time)
                 {
                  last_open_time = OrderOpenTime();
                  last_open_price = OrderOpenPrice();
                  last_order_ticket = OrderTicket();
                 }
              }
           }

         if(last_order_ticket != -1)
           {
            for(int j=OrdersTotal()-1; j>=0; j--)
              {
               if(OrderSelect(j, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
                 {
                  RefreshRates();
                  if(OrderType() == OP_BUY && last_open_price < Ask)
                    {
                     if(!OrderModify(OrderTicket(), OrderOpenPrice(), last_open_price, OrderTakeProfit(), 0, clrNONE))
                        Print("OrderModify Error: ",GetLastError());
                    }
                  else if(OrderType() == OP_SELL && last_open_price > Bid)
                    {
                     if(!OrderModify(OrderTicket(), OrderOpenPrice(), last_open_price, OrderTakeProfit(), 0, clrNONE))
                        Print("OrderModify Error: ",GetLastError());
                    }
                 }
              }
           }
         ObjectSetInteger(0,"SetBE",OBJPROP_STATE,0);
         ChartRedraw();
        }

      // --- CLOSE ALL ---
      if(sparam == "CloseA")
        {
         ForceCloseAll();
         ObjectSetInteger(0,"CloseA",OBJPROP_STATE,0);
         ChartRedraw();
        }
     }
  }

//+------------------------------------------------------------------+
//| Standard Tick Handler                                            |
//+------------------------------------------------------------------+
int start()
  {
   CheckAndCloseOnMaxLoss();

   if(Digits==3 || Digits==5) dig=10;
   else dig=1;

   CheckLines();
   DeleteOldLines();

   if(OrdersTotal()>0)
     {
      for(int o=OrdersTotal()-1;o>=0;o--)
        {
         if(!OrderSelect(o,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderSymbol()==Symbol())
           {
            double thesl=ObjectGetDouble(0,IntegerToString(OrderTicket())+" SL",OBJPROP_PRICE1,0);
            double thetp=ObjectGetDouble(0,IntegerToString(OrderTicket())+" TP",OBJPROP_PRICE1,0);
           }
        }
     }
   return (0);
  }

//+------------------------------------------------------------------+
//| Automatic Account Drawdown Protection Logic                      |
//+------------------------------------------------------------------+
void CheckAndCloseOnMaxLoss()
{
   if(AccountBalance() <= 0) return;

   double maxLossLimit = StringToDouble(ObjectGetString(0, "MaxLossSize", OBJPROP_TEXT));
   if(maxLossLimit <= 0) maxLossLimit = InpMaxLossPercent;

   double currentLossPercent = ((AccountBalance() - AccountEquity()) / AccountBalance()) * 100.0;

   if(currentLossPercent >= maxLossLimit)
   {
      Alert("CRITICAL: Max account loss limit breached! Liquidation triggered.");
      ForceCloseAll();
     }
}

//+------------------------------------------------------------------+
//| Loop through all open positions on the account and close them   |
//+------------------------------------------------------------------+
void ForceCloseAll()
{
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;

      int ticket  = OrderTicket();
      double lots = OrderLots();
      int type    = OrderType();
      bool result = false;
      int retry   = 3;

      while(retry > 0)
        {
         RefreshRates();

         if(type == OP_BUY)       result = OrderClose(ticket, lots, Bid, 3, clrRed);
         else if(type == OP_SELL) result = OrderClose(ticket, lots, Ask, 3, clrRed);
         else if(type >= OP_BUYLIMIT && type <= OP_SELLSTOP)
         {
            result = OrderDelete(ticket, clrGray);
         }

         if(result) break;
         else
           {
            retry--;
            Sleep(200);
           }
        }
     }
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Placeholder structural stubs for incomplete custom logic functions|
//+------------------------------------------------------------------+
void CheckLines()
{
   // Add custom manual line checking logic here if applicable
}

void DeleteOldLines()
{
   // Add clean up logic for expired lines here if applicable
}