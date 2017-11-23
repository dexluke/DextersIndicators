//+------------------------------------------------------------------+
//|                                      Dexters Tail Range(DTR).mq4 |
//|                                                 "See Intro post" |
//|                               http://www.steemit.com/@dexterslab |
//+------------------------------------------------------------------+
#property copyright   "https://www.steemit.com/@dexterslab"
#property link        "https://www.steemit.com/@dexterslab"
#property description "Dexters Tail Range(DTR)"
#property description "Use to measure expected candle Stick tail Volatiity.->"
#property strict

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  DodgerBlue
//--- input parameter
input int SamplePeriod=14; // Sample Period
//--- buffers
double ExtATRBuffer[];
double ExtTRBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   string short_name;
//--- 1 additional buffer used for counting.
   IndicatorBuffers(2);
   IndicatorDigits(Digits);
//--- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtATRBuffer);
   SetIndexBuffer(1,ExtTRBuffer);
  
//--- name for DataWindow and indicator subwindow label
   short_name="DTR("+IntegerToString(SamplePeriod)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//--- check for input parameter
   if(SamplePeriod<=0)
     {
      Print("Wrong input parameter ATR Period=",SamplePeriod);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,SamplePeriod);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
//+------------------------------------------------------------------+
//-->Temp Data
double wd_a;
double wd_b;

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int i,limit;
//--- check for bars count and input parameter
   if(rates_total<=SamplePeriod || SamplePeriod<=0)
      return(0);
//--- counting from 0 to rates_total

   ArraySetAsSeries(ExtATRBuffer,false);
   ArraySetAsSeries(ExtTRBuffer,false);
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
//--- preliminary calculations
   if(prev_calculated==0)
     {
      ExtTRBuffer[0]=0.0;
      ExtATRBuffer[0]=0.0;
      //--- filling out the array of True Range values for each period
      for(i=1; i<rates_total; i++){
      
      if(Open[i]>Close[i])wd_a=NormalizeDouble((High[i] - Open[i]),Digits);
      if(Open[i]>Close[i])wd_b=NormalizeDouble((Close[i] -Low[i]),Digits);
      if(Open[i]<Close[i])wd_a=NormalizeDouble((Open[i] -Low[i]),Digits);
      if(Open[i]<Close[i])wd_b=NormalizeDouble((High[i] -Close[i]),Digits);
      
      
         ExtTRBuffer[i]= NormalizeDouble(((wd_a+wd_b)/2),Digits);
         }
      //--- first AtrPeriod values of the indicator are not calculated
      double firstValue=0.0;
      for(i=1; i<=SamplePeriod; i++)
        {
         ExtATRBuffer[i]=0.0;
         firstValue+=ExtTRBuffer[i];
        }
      //--- calculating the first value of the indicator
      firstValue/=SamplePeriod;
      ExtATRBuffer[SamplePeriod]=firstValue;
      limit=SamplePeriod+1;
     }
   else
      limit=prev_calculated-1;
//--- the main loop of calculations
   for(i=limit; i<rates_total; i++)
     {
      
      if(Open[i]>Close[i])wd_a=NormalizeDouble((High[i] - Open[i]),Digits);
      if(Open[i]>Close[i])wd_b=NormalizeDouble((Close[i] -Low[i]),Digits);
      if(Open[i]<Close[i])wd_a=NormalizeDouble((Open[i] -Low[i]),Digits);
      if(Open[i]<Close[i])wd_b=NormalizeDouble((High[i] -Close[i]),Digits);
      
      
      ExtTRBuffer[i]= NormalizeDouble(((wd_a+wd_b)/2),Digits);
      ExtATRBuffer[i]=ExtATRBuffer[i-1]+(ExtTRBuffer[i]-ExtTRBuffer[i-SamplePeriod])/SamplePeriod;
      
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
