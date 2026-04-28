//+------------------------------------------------------------------+
//|                                              Order Manager EA.mq4 |
//|                                          Copyright 2025, japarico |
//+------------------------------------------------------------------+
#import "user32.dll"
int MessageBoxA(int Ignore,string Caption,string Title,int Icon);
#import

#property strict

input double lotSize=0.1;//Lot Size
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
      ObjectSetString(0,"LotSize",OBJPROP_TEXT,"0.01");
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
      Sleep(500);
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
   ObjectDelete(0,"BuyMarket");
   ObjectDelete(0,"SellMarket");
   ObjectDelete(0,"CloseP");
   ObjectDelete(0,"CloseA");
   ObjectDelete(0,"SetBE");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Digits==4)
      dig=10;
   CheckLines();
   DeleteOldLines();

   // Handle Lot Size +/- buttons
   if(ObjectGetInteger(0,"LotMinus",OBJPROP_STATE,0)==true)
     {
      double currentLot = StringToDouble(ObjectGetString(0,"LotSize",OBJPROP_TEXT));
      currentLot = currentLot - 0.01;
      if(currentLot < 0.01)
         currentLot = 0.01;
      ObjectSetString(0,"LotSize",OBJPROP_TEXT,DoubleToStr(currentLot,2));
      ObjectSetInteger(0,"LotMinus",OBJPROP_STATE,0);
     }

   if(ObjectGetInteger(0,"LotPlus",OBJPROP_STATE,0)==true)
     {
      double currentLot = StringToDouble(ObjectGetString(0,"LotSize",OBJPROP_TEXT));
      currentLot = currentLot + 0.01;
      ObjectSetString(0,"LotSize",OBJPROP_TEXT,DoubleToStr(currentLot,2));
      ObjectSetInteger(0,"LotPlus",OBJPROP_STATE,0);
     }

   // Automatic SL/TP setting removed - orders are placed without SL/TP
//Manage SL, TP & Lock-in Points
   if(OrdersTotal()>0)
     {
      CheckLines();
      for(int o=OrdersTotal()-1;o>=0;o--)
        {
         if(!OrderSelect(o,SELECT_BY_POS,MODE_TRADES))
            continue;
         if(OrderSymbol()==Symbol())
           {
            double thesl=ObjectGetDouble(0,IntegerToString(OrderTicket())+" SL",OBJPROP_PRICE1,0);
            double thetp=ObjectGetDouble(0,IntegerToString(OrderTicket())+" TP",OBJPROP_PRICE1,0);
           }
        }
     }
//Check buttons
   if(ObjectGetInteger(0,"BuyMarket",OBJPROP_STATE,0)==true)
     {
      double currentLotSize = StringToDouble(ObjectGetString(0,"LotSize",OBJPROP_TEXT));
      if(!OrderSend(Symbol(),OP_BUY,currentLotSize,Ask,0,NULL,NULL,NULL,0,0,0))
         Print("OrderSend Error: ",GetLastError());
      ObjectSetInteger(0,"BuyMarket",OBJPROP_STATE,0);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ObjectGetInteger(0,"SellMarket",OBJPROP_STATE,0)==true)
     {
      double currentLotSize = StringToDouble(ObjectGetString(0,"LotSize",OBJPROP_TEXT));
      if(!OrderSend(Symbol(),OP_SELL,currentLotSize,Bid,0,NULL,NULL,NULL,0,0,0))
         Print("OrderSend Error: ",GetLastError());
      ObjectSetInteger(0,"SellMarket",OBJPROP_STATE,0);
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(ObjectGetInteger(0,"CloseP",OBJPROP_STATE,0)==true)
     {
      for(int i=OrdersTotal()-1;i>=0;i--)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            continue;
         if(OrderProfit()+OrderSwap()+OrderCommission()>=0)
           {
            RefreshRates();
            if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,0))
               Print("OrderClose Error: ",GetLastError());
           }
        }
      ObjectSetInteger(0,"CloseP",OBJPROP_STATE,0);
     }

      if(ObjectGetInteger(0,"SetBE",OBJPROP_STATE,0)==true)
     {
      datetime last_open_time = 0;
      double last_open_price = 0;
      int last_order_ticket = -1;

      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderSymbol() == Symbol())
              {
               if(OrderOpenTime() > last_open_time)
                 {
                  last_open_time = OrderOpenTime();
                  last_open_price = OrderOpenPrice();
                  last_order_ticket = OrderTicket();
                 }
              }
           }
        }

      if(last_order_ticket != -1)
        {
         for(int j=OrdersTotal()-1; j>=0; j--)
           {
            if(OrderSelect(j, SELECT_BY_POS, MODE_TRADES))
              {
               if(OrderSymbol() == Symbol())
                 {
                   if(OrderType() == OP_BUY)
                   {
                       if(last_open_price < Ask)
                       {
                           if(!OrderModify(OrderTicket(), OrderOpenPrice(), last_open_price, OrderTakeProfit(), 0, clrNONE))
                               Print("OrderModify Error: ",GetLastError());
                       }
                   }
                   else if(OrderType() == OP_SELL)
                   {
                       if(last_open_price > Bid)
                       {
                           if(!OrderModify(OrderTicket(), OrderOpenPrice(), last_open_price, OrderTakeProfit(), 0, clrNONE))
                               Print("OrderModify Error: ",GetLastError());
                       }
                   }
                 }
              }
           }
        }
      ObjectSetInteger(0,"SetBE",OBJPROP_STATE,0);
     // Sleep(500);
     }

   if(ObjectGetInteger(0,"CloseA",OBJPROP_STATE,0)==true)
     {
      for(int i=OrdersTotal()-1;i>=0;i--)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            continue;
         RefreshRates();
         if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,0))
            Print("OrderClose Error: ",GetLastError());
        }
      ObjectSetInteger(0,"CloseA",OBJPROP_STATE,0);
     }
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DashBuy()
  {

   if(ObjectType("ARJUN 10EMA Dashboard v1.00EURUSDM15")==22 && ObjectType("ARJUN 10EMA Dashboard v1.00EURUSDM30")==22)
      return(true);

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DashSell()
  {
   if(ObjectType("ARJUN 10EMA Dashboard v1.00EURUSDM15")==23 && ObjectType("ARJUN 10EMA Dashboard v1.00EURUSDM30")==23)
      return(true);

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuyKumo()
  {
   bool buy=true;
   int t=15;
   double close=MarketInfo(Symbol(),MODE_BID);
   if(close>0)
     {
      double dPoint=MarketInfo(Symbol(),MODE_POINT);
      if(dPoint==0.00001 || dPoint==0.001)
         dPoint*=10;

      double UpKumo = iIchimoku( Symbol(), t, 9, 26, 52,  3, 0 );
      double DnKumo = iIchimoku( Symbol(), t, 9, 26, 52,  4, 0 );

      double min = MathMin( UpKumo, DnKumo );
      double max = MathMax( UpKumo, DnKumo );


      double dist=0;
      if(close<min)
         dist=close-min;
      else if(close>max)
         dist=close-max;
      dist/=dPoint;

      if(dist<0)
         buy=false;
     }

   if(buy==true)
      return(true);

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SellKumo()
  {
   bool sell=true;
   int t=15;
   double close=MarketInfo(Symbol(),MODE_BID);
   if(close>0)
     {
      double dPoint=MarketInfo(Symbol(),MODE_POINT);
      if(dPoint==0.00001 || dPoint==0.001)
         dPoint*=10;

      double UpKumo = iIchimoku( Symbol(), t, 9, 26, 52,  3, 0 );
      double DnKumo = iIchimoku( Symbol(), t, 9, 26, 52,  4, 0 );

      double min = MathMin( UpKumo, DnKumo );
      double max = MathMax( UpKumo, DnKumo );


      double dist=0;
      if(close<min)
         dist=close-min;
      else if(close>max)
         dist=close-max;
      dist/=dPoint;

      if(dist>0)
         sell=false;
     }

   if(sell==true)
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SyncBuy()
  {
   string syncpair;
   if(Symbol()==prefix+"EURUSD"+suffix)
      syncpair=prefix+"EURJPY"+suffix;
   if(Symbol()==prefix+"EURJPY"+suffix)
      syncpair=prefix+"EURUSD"+suffix;
   if(Symbol()==prefix+"GBPUSD"+suffix)
      syncpair=prefix+"GBPJPY"+suffix;
   if(Symbol()==prefix+"GBPJPY"+suffix)
      syncpair=prefix+"GBPUSD"+suffix;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(
      Bid>iOpen(Symbol(),PERIOD_H1,0) && 
      Bid>iOpen(Symbol(),PERIOD_H4,0) && 
      Bid>iOpen(Symbol(),PERIOD_D1,0))
     {
      if(
         MarketInfo(syncpair,MODE_BID)>iOpen(syncpair,PERIOD_H1,0) && 
         MarketInfo(syncpair,MODE_BID)>iOpen(syncpair,PERIOD_H4,0) && 
         MarketInfo(syncpair,MODE_BID)>iOpen(syncpair,PERIOD_D1,0))
        {
         return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SyncSell()
  {
   string syncpair;
   if(Symbol()==prefix+"EURUSD"+suffix)
      syncpair=prefix+"EURJPY"+suffix;
   if(Symbol()==prefix+"EURJPY"+suffix)
      syncpair=prefix+"EURUSD"+suffix;
   if(Symbol()==prefix+"GBPUSD"+suffix)
      syncpair=prefix+"GBPJPY"+suffix;
   if(Symbol()==prefix+"GBPJPY"+suffix)
      syncpair=prefix+"GBPUSD"+suffix;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Bid<iOpen(Symbol(),PERIOD_H1,0) && 
      Bid<iOpen(Symbol(),PERIOD_H4,0) && 
      Bid<iOpen(Symbol(),PERIOD_D1,0))
     {
      if(MarketInfo(syncpair,MODE_BID)<iOpen(syncpair,PERIOD_H1,0) && 
         MarketInfo(syncpair,MODE_BID)<iOpen(syncpair,PERIOD_H4,0) && 
         MarketInfo(syncpair,MODE_BID)<iOpen(syncpair,PERIOD_D1,0))
        {
         return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HasStrengthBuy()
  {
   string symbolstring=Symbol();
   string parta=StringSubstr(symbolstring,0,3);
   string partb=StringSubstr(symbolstring,3,6);
   double EUR = StringSubstr(ObjectDescription("CurrencyStrength-0-1"),3,6);
   double USD = StringSubstr(ObjectDescription("CurrencyStrength-0-0"),3,6);
   double GBP = StringSubstr(ObjectDescription("CurrencyStrength-0-2"),3,6);
   double JPY = StringSubstr(ObjectDescription("CurrencyStrength-0-6"),3,6);

   if(Symbol()==prefix+"EURUSD"+suffix && (EUR>=7.5 || USD<=2))
      return(true);
   if(Symbol()==prefix+"EURJPY"+suffix && (EUR>=7.5 || JPY<=2))
      return(true);
   if(Symbol()==prefix+"GBPUSD"+suffix && (GBP>=7.5 || USD<=2))
      return(true);
   if(Symbol()==prefix+"GBPJPY"+suffix && (GBP>=7.5 || JPY<=2))
      return(true);

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HasStrengthSell()
  {
   string symbolstring=Symbol();
   string parta=StringSubstr(symbolstring,0,3);
   string partb=StringSubstr(symbolstring,3,6);
   double EUR = StringSubstr(ObjectDescription("CurrencyStrength-0-1"),3,6);
   double USD = StringSubstr(ObjectDescription("CurrencyStrength-0-0"),3,6);
   double GBP = StringSubstr(ObjectDescription("CurrencyStrength-0-2"),3,6);
   double JPY = StringSubstr(ObjectDescription("CurrencyStrength-0-6"),3,6);

   if(Symbol()==prefix+"EURUSD"+suffix && (EUR<=2 || USD>=7.5))
      return(true);
   if(Symbol()==prefix+"EURJPY"+suffix && (EUR<=2 || JPY>=7.5))
      return(true);
   if(Symbol()==prefix+"GBPUSD"+suffix && (GBP<=2 || USD>=7.5))
      return(true);
   if(Symbol()==prefix+"GBPJPY"+suffix && (GBP<=2 || JPY>=7.5))
      return(true);

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckSRAbove()
  {
//MessageBoxA(0,"Got the 1000th tick!","Pause...",64);
   double price=Bid;
   double S1 = ObjectGetDouble(0,"S1_Line",OBJPROP_PRICE,0);
   double R1 = ObjectGetDouble(0,"R1_Line",OBJPROP_PRICE,0);
   double Piv= ObjectGetDouble(0,"PivotLine",OBJPROP_PRICE,0);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(
      (S1-price<=(100*Point) && S1-price>0) ||
      (R1-price<=(100*Point) && R1-price>0) ||
      (Piv-price<=(100*Point) && Piv-price>0))
     {
      return(true);
     }
   prevtime=iTime(Symbol(),0,0);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckSRBelow()
  {
//MessageBoxA(0,"Got the 1000th tick!","Pause...",64);
   double price=Bid;
   double S1 = ObjectGetDouble(0,"S1_Line",OBJPROP_PRICE,0);
   double R1 = ObjectGetDouble(0,"R1_Line",OBJPROP_PRICE,0);
   double Piv= ObjectGetDouble(0,"PivotLine",OBJPROP_PRICE,0);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(
      (price-S1<=(100*Point) && price-S1>0) ||
      (price-R1<=(100*Point) && price-R1>0) ||
      (price-Piv<=(100*Point) && price-Piv>0))
     {
      return(true);
     }
   prevtime=iTime(Symbol(),0,0);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Check100()
  {
//MessageBoxA(0,"Got the 1000th tick!","Pause...",64);
   double price=Bid;
   price/=Point;
   int checkpoint=price/1000;
   checkpoint*=1000;
   int ref=MathCeil(price-checkpoint);
   if(ref-100<=0)
      return(true);
   prevtime=iTime(Symbol(),0,0);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Check900()
  {
//MessageBoxA(0,"Got the 1000th tick!","Pause...",64);
   double price=Bid;
   price/=Point;
   int checkpoint=price/1000;
   checkpoint*=1000;
   int ref=MathCeil(price-checkpoint);
   if(1000-ref<=100)
      return(true);
   prevtime=iTime(Symbol(),0,0);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckLines()
  {
   if(OrdersTotal()>0)
     {
      double sl,tp;
      for(int c=OrdersTotal()-1;c>=0;c--)
        {
         if(!OrderSelect(c,SELECT_BY_POS,MODE_TRADES))
            continue;
         if(OrderSymbol()==Symbol())
           {
            if(OrderType()==OP_BUY)
              {
               sl=OrderOpenPrice()-(tsl*Point);
               if(ObjectFind(0,OrderTicket()+" SL")<0)
                 {
                  int bars=iBarShift(Symbol(),0,OrderOpenTime());
                  for(int p=0;p<=bars;p++)
                    {
                     if(High[p]>=OrderOpenPrice()+(alip*Point))
                        sl=OrderOpenPrice()+(lip*Point);
                    }
                  ObjectCreate(0,IntegerToString(OrderTicket())+" SL",OBJ_HLINE,0,iTime(Symbol(),0,0),sl);
                  ObjectSetInteger(0,IntegerToString(OrderTicket())+" SL",OBJPROP_COLOR,clrRed);
                  ObjectSet(IntegerToString(OrderTicket())+" SL",OBJPROP_STYLE,STYLE_DASHDOT);
                 }
               tp=OrderOpenPrice()+(ttp*Point);
               if(ObjectFind(0,OrderTicket()+" TP")<0)
                 {
                  ObjectCreate(0,IntegerToString(OrderTicket())+" TP",OBJ_HLINE,0,iTime(Symbol(),0,0),tp);
                  ObjectSetInteger(0,IntegerToString(OrderTicket())+" TP",OBJPROP_COLOR,clrLime);
                  ObjectSet(IntegerToString(OrderTicket())+" TP",OBJPROP_STYLE,STYLE_DASHDOT);

                 }
              }
            if(OrderType()==OP_SELL)
              {
               sl=OrderOpenPrice()+(tsl*Point);
               if(ObjectFind(0,OrderTicket()+" SL")<0)
                 {
                  int bars=iBarShift(Symbol(),0,OrderOpenTime());
                  for(int p=0;p<=bars;p++)
                    {
                     if(Low[p]<=OrderOpenPrice()-(alip*Point))
                        sl=OrderOpenPrice()-(lip*Point);
                    }
                  ObjectCreate(0,IntegerToString(OrderTicket())+" SL",OBJ_HLINE,0,iTime(Symbol(),0,0),sl);
                  ObjectSetInteger(0,IntegerToString(OrderTicket())+" SL",OBJPROP_COLOR,clrRed);
                  ObjectSet(IntegerToString(OrderTicket())+" SL",OBJPROP_STYLE,STYLE_DASHDOT);
                 }
               tp=OrderOpenPrice()-(ttp*Point);
               if(ObjectFind(0,OrderTicket()+" TP")<0)
                 {
                  ObjectCreate(0,IntegerToString(OrderTicket())+" TP",OBJ_HLINE,0,iTime(Symbol(),0,0),tp);
                  ObjectSetInteger(0,IntegerToString(OrderTicket())+" TP",OBJPROP_COLOR,clrLime);
                  ObjectSet(IntegerToString(OrderTicket())+" TP",OBJPROP_STYLE,STYLE_DASHDOT);

                 }
              }
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteOldLines()
  {
   for(int i=ObjectsTotal()-1;i>=0;i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(ObjectType(ObjectName(i))==OBJ_HLINE)
        {
         string to_split=ObjectName(i);   // A string to split into substrings
         string sep=" ";                // A separator as a character
         ushort u_sep;                  // The code of the separator character
         string result[];               // An array to get strings
         u_sep=StringGetCharacter(sep,0);
         int k=StringSplit(to_split,u_sep,result);
         //
         bool deleteit=true;

         for(int j=OrdersTotal()-1;j>=0;j--)
           {
            if(!OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
               continue;
            if(OrderSymbol()==Symbol())
              {

               if(OrderTicket()==result[0])
                 {
                  deleteit=false;
                  break;
                 }
              }
           }
         if(ArraySize(result)>1)
           {
            if(deleteit && (result[1]=="TP" || result[1]=="SL"))
              {;
               ObjectDelete(0,ObjectName(i));
              }
           }
        }

     }

   return;
  }
//+------------------------------------------------------------------+
