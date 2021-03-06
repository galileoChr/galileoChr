//+------------------------------------------------------------------+
//|                                         Donchian Test Expert.mq5 |
//|                                 Copyright 2021, Christophe Manzi.|
//|                                             https://www.CM.com |
//+------------------------------------------------------------------+a
#property copyright "Copyright 2021, Christophe Manzi."
#property link      "https://CM.com"
#property version   "1.00"

#include <CandlestickType.mqh>
//+------------------------------------------------------------------+
//|  Declaration of enumerations of strategy types                   |
//+------------------------------------------------------------------+
enum Strategy
  {
   Donchian=0,
   Donchian_ADX,
   Donchian_MACD,
   Donchian_AvrSpeed_RSI
  };
//+------------------------------------------------------------------+
//| Declaration of enumerations of extreme types                     |
//+------------------------------------------------------------------+
enum Applied_Extrem
  {
   HIGH_LOW,
   HIGH_LOW_OPEN,
   HIGH_LOW_CLOSE,
   OPEN_HIGH_LOW,
   CLOSE_HIGH_LOW
  };
#include <Trade\Trade.mqh>
CTrade trade;
//+------------------------------------------------------------------+
//| Expert Advisor input parameters                                  |
//+------------------------------------------------------------------+
sinput string              Inp_EaComment="Donchian Expert";             //EA comment
//input double               Inp_Lot=0.0045;                                //Basic lot
////input MarginMode           Inp_MMode=LOT;                               //Money Management
//input int                  Inp_MagicNum=555;                            //Magic
//input int                  Inp_StopLoss=400;                            //Stop Loss (in points)
//input int                  Inp_TakeProfit=600;                          //Take Profit (in points)
////input int                  Inp_Deviation = 20;                          //Slippage
//input ENUM_TIMEFRAMES      InpInd_Timeframe=PERIOD_H1;                  //Working timeframe
//input bool                 InfoPanel=true;                              //Display of the information panel
////--- Donchian Channel System indicator parameters
//
input uint                 DonchianPeriod=1;                           //Channel period
input Applied_Extrem       Extremes=HIGH_LOW_CLOSE;                     //Type of extrema


int      InpInd_Handle1_DonChInd,InpInd_Handle_S_P,InpInd_Handle_S_P_2,InpInd_Handle1_DonChInd_Ind2;
int InpInd_Handle_S_P_D,InpInd_Handle_S_P_D_2;
double   dcs_up[],dcs_midd[],dcs_low[],close[],high[],low[];
double   adx[],adx_m[],adx_p[];
double   macd_m[],macd_s[];
double   avs[];
double   rsi_1b[],rsi_2b[],rsi_3b[],rsi_4b[];
double   rsi_1s[],rsi_2s[],rsi_3s[],rsi_4s[];

//input uchar Period_RSI=8;     // RSI period
//input int Analyze_Bars= 300;  // How many bars in history to analyze
//input double Low_RSI = 35.0;  // Lower RSI level for finding extremum
//input double High_RSI= 65.0;  // Higher RSI level for finding extremum
//input float Distans=13.0;     // Deviation of RSI level
double support_Data[], resistance_Data[],support_Data_2[], resistance_Data_2[];
double support_Data_D[], resistance_Data_D[],support_Data_D_2[], resistance_Data_D_2[];

// Used by Key Reversal.
int InpInd_HandleKey_Rever;
double         BufferTKR[];
double         BufferBKR[];

// Used by Key Levels.
int indicator_handleKeyL;

// Used by Chandelier exit
int indicator_handleChandlExit;
double UplBuffer1[],UpdBuffer1[],DnlBuffer1[],DndBuffer1[],UplBuffer2[],UpdBuffer2[],DnlBuffer2[],DndBuffer2[];

// Used by CandleStick Patterns And colors.
int indicator_handleCandlePatt;
int indicator_handleCandleTypeColor,indicator_handleCandleTypeColor_D;

double ExtOpen[];
double ExtHigh[];
double ExtLow[];
double ExtClose[];
double ExtColor[];
double ExtOpen_D[];
double ExtHigh_D[];
double ExtLow_D[];
double ExtClose_D[];
double ExtColor_D[];

// Used by BreakOutBox.
int indicator_handleBreakOutB;
// Used by Moving Average
int movingAverage_handle, movingAverage_handle_2, movingAverage_handle_3, movingAverage_handle_4;
// Used by Moving Average Daily
int movingAverage_handle_D, movingAverage_handle_D_2, movingAverage_handle_D_3, movingAverage_handle_D_4;

// Used by MA
//--- input parameters
input int            InpMAPeriod=14;         // Period
input int            InpMAShift=0;           // Shift
input ENUM_MA_METHOD InpMAMethod=MODE_EMA;  // Method

// Used by pattern_on_chsrt
int indicator_handlePatternChart;
double upArrow[4];
double downArrow[4];
double checkTruthGetPointsBuffer[3];

// Used by MQLTA MT5 Support Resistance Lines
int indicator_handleSupportResistanceL, indicator_handleSupportResistanceL_2;
double BufferZero[];
double BufferOne[];
double BufferTwo[];
double BufferThree[];
double BufferFour[];
double BufferFive[];
double BufferSix[];
double BufferSeven[];
double EnteringZone[];
double BufferArray[];

double BufferZero_2[];
double BufferOne_2[];
double BufferTwo_2[];
double BufferThree_2[];
double BufferFour_2[];
double BufferFive_2[];
double BufferSix_2[];
double BufferSeven_2[];

// Used by Trend_Range
int indicator_handleTrendRange;
//--- input parameters
input uint           InpPeriodTR    =  10;         // Period
input ENUM_MA_METHOD InpMethod      =  MODE_EMA;   // Method
input double         InpDeviation   =  1.0;        // Deviation
//--- indicator buffers
double         BufferMax[];
double         BufferFlat[];
double         BufferHist[];
double         BufferColors[];
double         BufferMA[];
double         BufferMADevTmp[];
double         BufferDev[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
// For returning desired period.
ENUM_TIMEFRAMES getPeriod = Period();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   iDigits=_Digits;
   if(_Digits==5 || _Digits==3)
      dXPoint=10;
   if(_Digits==3)
      iDigits=2;
   if(_Digits==5)
      iDigits=4;
   Div=0.1/(_Point*dXPoint);

//indicator_handlePatternChart = iCustom(Symbol(),getPeriod,"patterns_on_chart");

   InpInd_Handle1_DonChInd=iCustom(Symbol(),getPeriod,"DC_Ind",
                                   720,
                                   Extremes
                                  );
//InpInd_Handle1_DonChInd_Ind2 =iCustom(Symbol(),getPeriod,"DC_Ind",
//                                      9,
//                                      Extremes
//                                     );
   InpInd_Handle_S_P = iCustom(Symbol(),getPeriod,"s_rind",4,300,30,70,13.0);
   InpInd_Handle_S_P_2 = iCustom(Symbol(),getPeriod,"s_rind_2",8,500,30,70,13.0);

   InpInd_Handle_S_P_D = iCustom(Symbol(),PERIOD_D1,"s_rind_D",4,300,30,70,13.0);
   InpInd_Handle_S_P_D_2 = iCustom(Symbol(),PERIOD_D1,"s_rind_D_2",8,500,30,70,13.0);
//InpInd_HandleKey_Rever = iCustom(Symbol(),getPeriod,"Key_Reversal");
   indicator_handleSupportResistanceL = iCustom(Symbol(),PERIOD_H4,"MQLTA MT5 Support Resistance Lines");
   indicator_handleSupportResistanceL_2 = iCustom(Symbol(),PERIOD_D1,"MQLTA MT5 Support Resistance Lines_2");



//indicator_handleChandlExit = iCustom(Symbol(),Period(),"Chandelier exit");

//indicator_handleCandlePatt = iCustom(Symbol(),getPeriod,"candlestick_patterns");

   indicator_handleCandleTypeColor = iCustom(Symbol(),getPeriod,"candlestick_type_color");
   indicator_handleCandleTypeColor_D = iCustom(Symbol(),PERIOD_D1,"candlestick_type_color_2");
//indicator_handleBreakOutB = iCustom(Symbol(),Period(),"BreakOutBox");
//indicator_handleKeyL  = iCustom(Symbol(),Period(),"Key_Levels");
   iCustom(Symbol(),PERIOD_D1,"Custom Moving Average_1",8,0,MODE_EMA);
   iCustom(Symbol(),PERIOD_D1,"Custom Moving Average_2",14,0,MODE_EMA);
   iCustom(Symbol(),PERIOD_D1,"Custom Moving Average_3",32,0,MODE_EMA);
   movingAverage_handle = iCustom(Symbol(),getPeriod,"Custom Moving Average_1",8,0,MODE_EMA);
   movingAverage_handle_2 = iCustom(Symbol(),getPeriod,"Custom Moving Average_2",14,0,MODE_EMA);
   movingAverage_handle_3 = iCustom(Symbol(),getPeriod,"Custom Moving Average_3",32,0,MODE_EMA);

   movingAverage_handle_D = iCustom(Symbol(),getPeriod,"Custom Moving Average_D_1",192,0,MODE_EMA);
   movingAverage_handle_D_2 = iCustom(Symbol(),getPeriod,"Custom Moving Average_D_2",336,0,MODE_EMA);
   movingAverage_handle_D_3 = iCustom(Symbol(),getPeriod,"Custom Moving Average_D_3",768,0,MODE_EMA);


   indicator_handleTrendRange = iCustom(Symbol(),getPeriod,"Trend_Range",12,MODE_EMA,1.0);
   //if(InpInd_Handle1_DonChInd==INVALID_HANDLE)
   //  {
   //   Print("Failed to create indicator DonChInd");
   //   return(INIT_FAILED);
   //  }
   //if(InpInd_Handle_S_P==INVALID_HANDLE || InpInd_Handle_S_P_2==INVALID_HANDLE)
   //  {
   //   Print("Failed to create indicator s_rind");
   //   return(INIT_FAILED);
   //  }
   //if(InpInd_Handle_S_P_D==INVALID_HANDLE || InpInd_Handle_S_P_D_2==INVALID_HANDLE)
   //  {
   //   Print("Failed to create indicator s_rind Daily");
   //   return(INIT_FAILED);
   //  }
   //if(indicator_handleSupportResistanceL==INVALID_HANDLE || indicator_handleSupportResistanceL_2==INVALID_HANDLE)
   //  {
   //   Print("Failed to create indicator MQLTA MT5 Support Resistance Lines or MQLTA MT5 Support Resistance Lines_2");
   //   return(INIT_FAILED);
   //  }
   //if(indicator_handleCandleTypeColor==INVALID_HANDLE || indicator_handleCandleTypeColor_D == INVALID_HANDLE)
   //  {
   //   Print("Failed to create indicator candlestick_type_color");
   //   return(INIT_FAILED);
   //  }
   //if(movingAverage_handle==INVALID_HANDLE || movingAverage_handle_2==INVALID_HANDLE || movingAverage_handle_3==INVALID_HANDLE)
   //  {
   //   Print("Failed to create indicator Custom Moving Average1,2,3");
   //   return(INIT_FAILED);
   //  }
   //if(indicator_handleTrendRange==INVALID_HANDLE)
   //  {
   //   Print("Failed to create indicator Trend_Range");
   //   return(INIT_FAILED);
   //  }





//--- success
   return(INIT_SUCCEEDED);

  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(InpInd_Handle1_DonChInd);
   IndicatorRelease(InpInd_Handle_S_P);
   IndicatorRelease(InpInd_Handle_S_P_2);
   IndicatorRelease(InpInd_Handle_S_P_D);
   IndicatorRelease(InpInd_Handle_S_P_D_2);
   IndicatorRelease(indicator_handleSupportResistanceL);
   IndicatorRelease(indicator_handleSupportResistanceL_2);
   IndicatorRelease(indicator_handleCandleTypeColor);
   IndicatorRelease(indicator_handleCandleTypeColor_D);
   IndicatorRelease(movingAverage_handle);
   IndicatorRelease(movingAverage_handle_2);
   IndicatorRelease(movingAverage_handle_3);
   IndicatorRelease(movingAverage_handle_D);
   IndicatorRelease(movingAverage_handle_D_2);
   IndicatorRelease(movingAverage_handle_D_3);
   IndicatorRelease(indicator_handleTrendRange);

  }

bool checker_EntrySec = true;
bool checker_EntrySec_2 = true;
bool checker_EntryFirst = true;
bool checker_EntryFirst_2 = true;
// These variables are for new entry rule with Intraday
int counting = 0;
bool checking = false;
double stopL;
double takeProfit;

// by moving averages
int MA_Cross_8_14_P = -1;
int MA_Cross_14_32_P = -1;
double price_MA_Crossed;
// by moving averages of DAILY
int MA_Cross_8_14_P_Daily = -1;
int MA_Cross_14_32_P_Daily = -1;
double price_MA_Crossed_Daily;

MqlRates rates[];
MqlRates Dailyrates[];
CANDLE_STRUCTURE candleType;

int BullishCandleStatus = 1;
int  BearishCandleStatus = 0;
int BullishCandleStatus_D = 1;
int  BearishCandleStatus_D = 0;

int CandleStickStatus;
int CandleStickIndecisionStatus;
int CandleStickStatus_D;
int CandleStickIndecisionStatus_D;

double Ask ;
double Bid ;
// Not used
bool countingCheck = false;

bool lockedChecker = false;

int BreakStrStatus;
int BreakStrStatus_D;

// Used by Stop Loss And Takr Profit
double SuppResTestArray[8],SuppResTestArray_2[8] ;
double differenceCurrentRatesKeySuppResis[8];

// Used by MA
double myMovingAverageArray_lowPer[];
double myMovingAverageArray_highPer[];
double goldenMovingAverageArray[];
int goldenMAStatus = -1;
// Used by MA_Daily
double myMovingAverageArray_lowPer_D[];
double myMovingAverageArray_highPer_D[];
double goldenMovingAverageArray_D[];
int goldenMAStatus_D = -1;

// This variable is for changing lower timeframe period of Supp/Resistance lines
// when it becomes too thin.
//ENUM_TIMEFRAMES changePeriod = PERIOD_M15;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitializeSupport_ResistanceLines()
  {
   ArraySetAsSeries(BufferZero,true);
   ArraySetAsSeries(BufferOne,true);
   ArraySetAsSeries(BufferTwo,true);
   ArraySetAsSeries(BufferThree,true);
   ArraySetAsSeries(BufferFour,true);
   ArraySetAsSeries(BufferFive,true);
   ArraySetAsSeries(BufferSix,true);
   ArraySetAsSeries(BufferSeven,true);

   ArraySetAsSeries(BufferArray,true);

   ArraySetAsSeries(BufferZero_2,true);
   ArraySetAsSeries(BufferOne_2,true);
   ArraySetAsSeries(BufferTwo_2,true);
   ArraySetAsSeries(BufferThree_2,true);
   ArraySetAsSeries(BufferFour_2,true);
   ArraySetAsSeries(BufferFive_2,true);
   ArraySetAsSeries(BufferSix_2,true);
   ArraySetAsSeries(BufferSeven_2,true);
// Used by MQLTA MT5 Support Resistance Lines
   CopyBuffer(indicator_handleSupportResistanceL,0,0,3,BufferZero);
   CopyBuffer(indicator_handleSupportResistanceL,1,0,3,BufferOne);
   CopyBuffer(indicator_handleSupportResistanceL,2,0,3,BufferTwo);
   CopyBuffer(indicator_handleSupportResistanceL,3,0,3,BufferThree);
   CopyBuffer(indicator_handleSupportResistanceL,4,0,3,BufferFour);
   CopyBuffer(indicator_handleSupportResistanceL,5,0,3,BufferFive);
   CopyBuffer(indicator_handleSupportResistanceL,6,0,3,BufferSix);
   CopyBuffer(indicator_handleSupportResistanceL,7,0,3,BufferSeven);
   CopyBuffer(indicator_handleSupportResistanceL,8,0,3,EnteringZone);
// VERSION 2
   CopyBuffer(indicator_handleSupportResistanceL_2,0,0,3,BufferZero_2);
   CopyBuffer(indicator_handleSupportResistanceL_2,1,0,3,BufferOne_2);
   CopyBuffer(indicator_handleSupportResistanceL_2,2,0,3,BufferTwo_2);
   CopyBuffer(indicator_handleSupportResistanceL_2,3,0,3,BufferThree_2);
   CopyBuffer(indicator_handleSupportResistanceL_2,4,0,3,BufferFour_2);
   CopyBuffer(indicator_handleSupportResistanceL_2,5,0,3,BufferFive_2);
   CopyBuffer(indicator_handleSupportResistanceL_2,6,0,3,BufferSix_2);
   CopyBuffer(indicator_handleSupportResistanceL_2,7,0,3,BufferSeven_2);

// SL/TP confluence Price

// FOR LOWER TIMEFRAME (5 MIN OR 15 MIN )
   SuppResTestArray[0]=BufferZero[0];
   SuppResTestArray[1]=BufferOne[0];
   SuppResTestArray[2]=BufferTwo[0];
   SuppResTestArray[3]=BufferThree[0];
   SuppResTestArray[4]=BufferFour[0];
   SuppResTestArray[5]=BufferFive[0];
   SuppResTestArray[6]=BufferSix[0];
   SuppResTestArray[7]=BufferSeven[0];

// fOR DAILY/HIGHER TIMEFRAME
   SuppResTestArray_2[0]=BufferZero_2[0];
   SuppResTestArray_2[1]=BufferOne_2[0];
   SuppResTestArray_2[2]=BufferTwo_2[0];
   SuppResTestArray_2[3]=BufferThree_2[0];
   SuppResTestArray_2[4]=BufferFour_2[0];
   SuppResTestArray_2[5]=BufferFive_2[0];
   SuppResTestArray_2[6]=BufferSix_2[0];
   SuppResTestArray_2[7]=BufferSeven_2[0];
  };

double y_arrayCycleSupp[3], y_arrayCycleSupp_2[3];
double y_arrayCycleResi[3], y_arrayCycleResi_2[3];
int x_arrayCycle[3], x_arrayCycle_2[3];
double theAngleSupp, theAngleSupp_2;
double theAngleResi, theAngleResi_2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrendLinesFunction()
  {
   ArraySetAsSeries(support_Data,true);
   ArraySetAsSeries(resistance_Data, true);
   ArraySetAsSeries(support_Data_2,true);
   ArraySetAsSeries(resistance_Data_2, true);
// Used by s_rind. Trendline
   CopyBuffer(InpInd_Handle_S_P,0,0,50,support_Data);
   CopyBuffer(InpInd_Handle_S_P,1,0,50,resistance_Data);
// Used by s_rind. Trendline_2
   CopyBuffer(InpInd_Handle_S_P_2,0,0,50,support_Data_2);
   CopyBuffer(InpInd_Handle_S_P_2,1,0,50,resistance_Data_2);
// Clear these arrays so that a new angle can be calculated:
   ArrayRemove(x_arrayCycle,0,WHOLE_ARRAY);
   ArrayRemove(y_arrayCycleSupp,0,WHOLE_ARRAY);
   ArrayRemove(x_arrayCycle_2,0,WHOLE_ARRAY);
   ArrayRemove(y_arrayCycleSupp_2,0,WHOLE_ARRAY);

// fast rate trendLines
   x_arrayCycle[0] = 1;
   x_arrayCycle[1] = 1+20;
   y_arrayCycleSupp[0] = support_Data[1];
   y_arrayCycleSupp[1] = support_Data[1+20];

// slow rate trendLines
   x_arrayCycle_2[0] = 1;
   x_arrayCycle_2[1] = 1+20;
   y_arrayCycleSupp_2[0] = support_Data_2[1];
   y_arrayCycleSupp_2[1] = support_Data_2[1+20];

//Print("Support Data["+i+"]: " + support_Data[i]);
//Print("y[0]: "+y_arrayCycleSupp[0]+" x[0]: "+x_arrayCycle[0]+" y[1]: "+y_arrayCycleSupp[1] + " x[1]: "+x_arrayCycle[1]);

// fast rate trendLines
   x_arrayCycle[0] = 1;
   x_arrayCycle[1] = 1+20;
   y_arrayCycleResi[0] = resistance_Data[1];
   y_arrayCycleResi[1] = resistance_Data[1+20];

// slow rate trendLines
   x_arrayCycle_2[0] = 1;
   x_arrayCycle_2[1] = 1+20;
   y_arrayCycleResi_2[0] = resistance_Data_2[1];
   y_arrayCycleResi_2[1] = resistance_Data_2[1+20];
// + " Res. Data["+i+"]: " +resistance_Data[i]
//Print("Support Data["+i+"]: " + support_Data[i]);
//Print("y[0]: "+y_arrayCycleSupp[0]+" x[0]: "+x_arrayCycle[0]+" y[1]: "+y_arrayCycleSupp[1] + " x[1]: "+x_arrayCycle[1]);
//}
//}
//Print("Angle Supp data points: " +x_arrayCycle[0]+" "+ x_arrayCycle[1]+" "+y_arrayCycleSupp[0]+" "+y_arrayCycleSupp[1]);
// fast rate trendLines
   theAngleSupp = calculateAngleSupp(x_arrayCycle[0],x_arrayCycle[1],y_arrayCycleSupp[0],y_arrayCycleSupp[1]);
   theAngleResi = calculateAngleResi(x_arrayCycle[0],x_arrayCycle[1],y_arrayCycleResi[0],y_arrayCycleResi[1]);
// slow rate trendLines
   theAngleSupp_2 = calculateAngleSupp(x_arrayCycle_2[0],x_arrayCycle_2[1],y_arrayCycleSupp_2[0],y_arrayCycleSupp_2[1]);
   theAngleResi_2 = calculateAngleResi(x_arrayCycle_2[0],x_arrayCycle_2[1],y_arrayCycleResi_2[0],y_arrayCycleResi_2[1]);
  }
double y_arrayCycleSupp_D[3], y_arrayCycleSupp_D_2[3];
double y_arrayCycleResi_D[3], y_arrayCycleResi_D_2[3];
int x_arrayCycle_D[3], x_arrayCycle_D_2[3];
double theAngleSupp_D, theAngleSupp_D_2;
double theAngleResi_D, theAngleResi_D_2;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DailyTrendLinesFunction()
  {
   ArraySetAsSeries(support_Data_D,true);
   ArraySetAsSeries(resistance_Data_D, true);
   ArraySetAsSeries(support_Data_D_2,true);
   ArraySetAsSeries(resistance_Data_D_2, true);
// Used by s_rind. Trendline
   CopyBuffer(InpInd_Handle_S_P_D,0,0,300,support_Data_D);
   CopyBuffer(InpInd_Handle_S_P_D,1,0,300,resistance_Data_D);
// Used by s_rind. Trendline_2
   CopyBuffer(InpInd_Handle_S_P_D_2,0,0,500,support_Data_D_2);
   CopyBuffer(InpInd_Handle_S_P_D_2,1,0,500,resistance_Data_D_2);
// Clear these arrays so that a new angle can be calculated:
   ArrayRemove(x_arrayCycle_D,0,WHOLE_ARRAY);
   ArrayRemove(y_arrayCycleSupp_D,0,WHOLE_ARRAY);
   ArrayRemove(x_arrayCycle_D_2,0,WHOLE_ARRAY);
   ArrayRemove(y_arrayCycleSupp_D_2,0,WHOLE_ARRAY);

// fast rate trendLines
   x_arrayCycle_D[0] = 24;
   x_arrayCycle_D[1] = 120;
   y_arrayCycleSupp_D[0] = support_Data_D[24];
   y_arrayCycleSupp_D[1] = support_Data_D[120];

// slow rate trendLines
   x_arrayCycle_D_2[0] = 24;
   x_arrayCycle_D_2[1] = 120;
   y_arrayCycleSupp_D_2[0] = support_Data_D_2[24];
   y_arrayCycleSupp_D_2[1] = support_Data_D_2[120];

//Print("Support Data["+i+"]: " + support_Data_D[i]);
//Print("y[0]: "+y_arrayCycleSupp[0]+" x[0]: "+x_arrayCycle[0]+" y[1]: "+y_arrayCycleSupp[1] + " x[1]: "+x_arrayCycle[1]);

// fast rate trendLines
   x_arrayCycle_D[0] = 24;
   x_arrayCycle_D[1] = 120;
   y_arrayCycleResi_D[0] = resistance_Data_D[24];
   y_arrayCycleResi_D[1] = resistance_Data_D[120];

// slow rate trendLines
   x_arrayCycle_D_2[0] = 24;
   x_arrayCycle_D_2[1] = 120;
   y_arrayCycleResi_D_2[0] = resistance_Data_D_2[24];
   y_arrayCycleResi_D_2[1] = resistance_Data_D_2[120];
// + " Res. Data["+i+"]: " +resistance_Data[i]
//Print("Support Data["+i+"]: " + support_Data_D[i]);
//Print("y[0]: "+y_arrayCycleSupp[0]+" x[0]: "+x_arrayCycle[0]+" y[1]: "+y_arrayCycleSupp[1] + " x[1]: "+x_arrayCycle[1]);
//}
//}
//Print("Angle Supp data points: " +x_arrayCycle[0]+" "+ x_arrayCycle[1]+" "+y_arrayCycleSupp[0]+" "+y_arrayCycleSupp[1]);
// fast rate trendLines
   theAngleSupp_D = calculateAngleSupp(x_arrayCycle_D[0],x_arrayCycle_D[1],y_arrayCycleSupp_D[0],y_arrayCycleSupp_D[1]);
   theAngleResi_D = calculateAngleResi(x_arrayCycle_D[0],x_arrayCycle_D[1],y_arrayCycleResi_D[0],y_arrayCycleResi_D[1]);
// slow rate trendLines
   theAngleSupp_D_2 = calculateAngleSupp(x_arrayCycle_D_2[0],x_arrayCycle_D_2[1],y_arrayCycleSupp_D_2[0],y_arrayCycleSupp_D_2[1]);
   theAngleResi_D_2 = calculateAngleResi(x_arrayCycle_D_2[0],x_arrayCycle_D_2[1],y_arrayCycleResi_D_2[0],y_arrayCycleResi_D_2[1]);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GeneralBufferCopying()
  {
// Used by Trend Range
   CopyBuffer(indicator_handleTrendRange,0,0,10, BufferMax);
   CopyBuffer(indicator_handleTrendRange,1,0,10, BufferFlat);
   CopyBuffer(indicator_handleTrendRange,2,0,10, BufferHist);
   CopyBuffer(indicator_handleTrendRange,3,0,10, BufferColors);



//CopyBuffer(indicator_handleSupportResistanceL_2,9,0,3,BufferArray);
// used by patterns on chart
   CopyBuffer(indicator_handlePatternChart,0,0,3,upArrow);
   CopyBuffer(indicator_handlePatternChart,1,0,3,downArrow);

//Used by TYPE Color 1 and 2
   CopyBuffer(indicator_handleCandleTypeColor,4,0,3,ExtColor);
   CopyBuffer(indicator_handleCandleTypeColor_D,4,0,3,ExtColor_D);
// by donCHind
   CopyBuffer(InpInd_Handle1_DonChInd,0,0,550,dcs_up);
   CopyBuffer(InpInd_Handle1_DonChInd,1,0,550,dcs_midd);
   CopyBuffer(InpInd_Handle1_DonChInd,2,0,550,dcs_low);

// Used by key Reversal.
   CopyBuffer(InpInd_HandleKey_Rever,0,0,10,BufferTKR); // Down
   CopyBuffer(InpInd_HandleKey_Rever,1,0,10,BufferBKR); // Up
// Used by Chandelier Exit
   CopyBuffer(indicator_handleChandlExit,0,0,4,UplBuffer1);
   CopyBuffer(indicator_handleChandlExit,1,0,4,DnlBuffer1);
   CopyBuffer(indicator_handleChandlExit,2,0,4,UplBuffer2);
   CopyBuffer(indicator_handleChandlExit,3,0,4,DnlBuffer2);
   CopyBuffer(indicator_handleChandlExit,4,0,4,UpdBuffer1);
   CopyBuffer(indicator_handleChandlExit,5,0,4,DndBuffer1);
   CopyBuffer(indicator_handleChandlExit,6,0,4,UpdBuffer2);
   CopyBuffer(indicator_handleChandlExit,7,0,4,DndBuffer2);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MA_Work()
  {
// **************************  Moving average defintion  ******************************** //

// Def.

   ArraySetAsSeries(myMovingAverageArray_lowPer, true);
   ArraySetAsSeries(myMovingAverageArray_highPer, true);
   ArraySetAsSeries(goldenMovingAverageArray, true);
   CopyBuffer(movingAverage_handle,0,0,8,myMovingAverageArray_lowPer);
   CopyBuffer(movingAverage_handle_2,0,0,8,myMovingAverageArray_highPer);
   CopyBuffer(movingAverage_handle_3,0,0,32,goldenMovingAverageArray);

// current candle
   double myMovingAverageValue = myMovingAverageArray_lowPer[1];
   double current_ma;


// Uptrend or DownTrend // **************


//   else
   if(
      myMovingAverageArray_lowPer[2] < rates[2].high && myMovingAverageArray_lowPer[2] > rates[2].low
      || myMovingAverageArray_lowPer[1] < rates[1].high && myMovingAverageArray_lowPer[1] > rates[1].low
   )
     {
      //Print("No TREND FOR NOW  !!!!");
      MA_Cross_8_14_P = -1;
     }

// Crossover bwteen 8-P and 14-P.
   if(myMovingAverageArray_lowPer[1]>myMovingAverageArray_highPer[1]
      && myMovingAverageArray_lowPer[2]<myMovingAverageArray_highPer[2])
     {
      MA_Cross_8_14_P=1;
      //Print("Crossed Up Up");
      price_MA_Crossed = rates[1].low;
     }

// Crossover bwteen 8-P and 14-P.
   if(myMovingAverageArray_lowPer[1]<myMovingAverageArray_highPer[1]
      && myMovingAverageArray_lowPer[2]>myMovingAverageArray_highPer[2])
     {
      //Print("Crossed Down Down");
      MA_Cross_8_14_P=0;
      price_MA_Crossed = rates[1].high;
     }

// Crossover bwteen 14-P and 32-P.
   if(myMovingAverageArray_highPer[1]>goldenMovingAverageArray[1]
      && myMovingAverageArray_highPer[2]<goldenMovingAverageArray[2])
     {
      MA_Cross_14_32_P=1;
      //Print("Crossed Up Up Golden");
     }

// Crossover bwteen 14-P and 32-P.
   if(myMovingAverageArray_highPer[1]<goldenMovingAverageArray[1]
      && myMovingAverageArray_highPer[2]>goldenMovingAverageArray[2])
     {
      //Print("Crossed Down Down Golden");
      MA_Cross_14_32_P=0;
     }

// ************************** ^^^^^  Moving average defintion ^^^^^ ******************************** //

// **************************  Moving average defintion DAILY ******************************** //

// Def.

   ArraySetAsSeries(myMovingAverageArray_lowPer_D, true);
   ArraySetAsSeries(myMovingAverageArray_highPer_D, true);
   ArraySetAsSeries(goldenMovingAverageArray_D, true);
   CopyBuffer(movingAverage_handle_D,0,0,8,myMovingAverageArray_lowPer_D);
   CopyBuffer(movingAverage_handle_D_2,0,0,8,myMovingAverageArray_highPer_D);
   CopyBuffer(movingAverage_handle_D_3,0,0,32,goldenMovingAverageArray_D);




// Uptrend or DownTrend // **************


//   else
   if(
      myMovingAverageArray_lowPer_D[2] < rates[2].high && myMovingAverageArray_lowPer_D[2] > rates[2].low
      || myMovingAverageArray_lowPer_D[1] < rates[1].high && myMovingAverageArray_lowPer_D[1] > rates[1].low
   )
     {
      //Print("No TREND FOR NOW  !!!!");
      MA_Cross_8_14_P_Daily = -1;
     }
// Crossover bwteen 8-P and 14-P.
   if(myMovingAverageArray_lowPer_D[1]>myMovingAverageArray_highPer_D[1]
      && myMovingAverageArray_lowPer_D[2]<myMovingAverageArray_highPer_D[2])
     {
      MA_Cross_8_14_P_Daily=1;
      //Print("Crossed Up Up");
      price_MA_Crossed_Daily = rates[1].low;
     }
// Crossover bwteen 8-P and 14-P.
   if(myMovingAverageArray_lowPer_D[1]<myMovingAverageArray_highPer_D[1]
      && myMovingAverageArray_lowPer_D[2]>myMovingAverageArray_highPer_D[2])
     {
      //Print("Crossed Down Down");
      MA_Cross_8_14_P_Daily=0;
      price_MA_Crossed_Daily = rates[1].high;
     }

// Crossover bwteen 14-P and 32-P.
   if(myMovingAverageArray_highPer_D[1]>goldenMovingAverageArray_D[1]
      && myMovingAverageArray_highPer_D[2]<goldenMovingAverageArray_D[2])
     {
      MA_Cross_14_32_P_Daily=1;
      //Print("Crossed Up Up Golden");
     }
// Crossover bwteen 14-P and 32-P.
   if(myMovingAverageArray_highPer_D[1]<goldenMovingAverageArray_D[1]
      && myMovingAverageArray_highPer_D[2]>goldenMovingAverageArray_D[2])
     {
      //Print("Crossed Down Down Golden");
      MA_Cross_14_32_P_Daily=0;
     }

// ************************** ^^^^^  Moving average defintion DAILY ^^^^^ ******************************** //

// Golden MA confluence: represents 4-Hour MA on an hourly Timeframe base
   if(goldenMovingAverageArray[1] < rates[3].close)
     {
      //Print("Up it's going. ");
      goldenMAStatus = 1;
     }
   if(goldenMovingAverageArray[1] > rates[3].close)
     {
      //Print("Down it's going. ");
      goldenMAStatus = 0;
     }
// Golden MA confluence: represents 4-Hour MA on an hourly Timeframe base ^^^^ //

// Golden MA confluence: represents 4-Hour MA on an hourly Timeframe base DAILY
   if(goldenMovingAverageArray_D[1] < rates[3].close)
     {
      //Print("Up it's going. ");
      goldenMAStatus_D = 1;
     }
   if(goldenMovingAverageArray_D[1] > rates[3].close)
     {
      //Print("Down it's going. ");
      goldenMAStatus_D = 0;
     }
// Golden MA confluence: represents 4-Hour MA on an hourly Timeframe base DAILY ^^^^ //

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SUPP_RES_Work()
  {
// Support and Resistance Definition


// Break Of Structure Confluence:
// break of Support
   if(support_Data[1] > rates[1].close && support_Data[1] > rates[2].close)
     {
      BreakStrStatus = 0;
      //Print("@@@@@@@@@@ Broken Down Down @@@@@@@@@@");
      //Print("Broken Structure Down");
     }
   else
      if(resistance_Data[1] < rates[1].close && resistance_Data[1] < rates[2].close)
        {
         BreakStrStatus = 1;
        }
      else
        {
         BreakStrStatus = -1;
        }
// Support and Resistance Definition Daily ====>>> //

// Support and Resistance Definition      //


// Break Of Structure Confluence:
// break of Support
   if(support_Data_D[0] > rates[1].close && support_Data_D[0] > rates[2].close)
     {
      BreakStrStatus_D = 0;
      //Print("@@@@@@@@@@ Broken Down Down @@@@@@@@@@");
      //Print("Broken Structure Down");
     }
   else
      if(resistance_Data_D[0] < rates[1].close && resistance_Data_D[0] < rates[2].close)
        {
         BreakStrStatus_D = 1;
        }
      else
        {
         BreakStrStatus_D = -1;
        }
// Support and Resistance Definition Daily ^^^^ //
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CandleType_Work()
  {
///      =================     Candle forming above/below MA and Price Action Confluence  ===============   ///


   BullishCandleStatus = -1;
   BearishCandleStatus = -1;
// bullish candle confirmation: one means up and zero means down
   if(rates[1].open < rates[1].close)
     {
      if(rates[1].close >=myMovingAverageArray_lowPer[1] || rates[1].close >=myMovingAverageArray_highPer[1])
        {
         BullishCandleStatus = 1;
         //BearishCandleStatus = -1;"
        }

     }
// bearish candle confirmation

   if(rates[1].open > rates[1].close)
     {
      if(rates[1].close <=myMovingAverageArray_lowPer[1] || rates[1].close <=myMovingAverageArray_highPer[1])
        {
         //BullishCandleStatus = -1;
         BearishCandleStatus = 0;
        }
     }

// candleStick Type:
//going up candles
   if(rates[1].open < rates[1].close)
     {
      CandleStickStatus = 1;
      if(ExtColor[1] ==1.0 || ExtColor[1] ==6.0)
        {
         CandleStickStatus = 1;
        }
      // indecision candle
      //if(ExtColor[1] ==3.0)
      //  {
      //   CandleStickStatus = 0;
      //  }

     }
   if(ExtColor[1] ==2.0 || ExtColor[1] ==5.0)
     {
      if(theAngleResi < 0)
        {
         CandleStickStatus = 1;
        }
     }
//going down candles
   if(rates[1].open > rates[1].close)
     {
      CandleStickStatus = 0;
      if(ExtColor[1] ==1.0 || ExtColor[1] ==6.0)
        {
         CandleStickStatus = 0;
        }
      // indecision candle
      //if(ExtColor[1] ==3.0)
      //  {
      //   CandleStickStatus = 1;
      //  }

     }
   if(ExtColor[1] ==2.0 || ExtColor[1] ==4.0)
     {
      if(theAngleSupp > 0)
        {
         CandleStickStatus = 0;
        }
     }
// Safety Check Confluence: SHort candles and None Candles are a good indication of indecision
   if(ExtColor[1] == 0.0 || ExtColor[1] == 7.0 || ExtColor[1] ==3.0)
     {
      //CandleStickStatus = -1;
      // don't trade.
      CandleStickIndecisionStatus = -1;
     }
   else
     {

      CandleStickIndecisionStatus = 1;
     }

///           Candle forming above/below MA and Price Action Definition     ///

///           Candle forming above/below MA and Price Action Confluence  Daily   ///


   BullishCandleStatus_D = -1;
   BearishCandleStatus_D = -1;
// bullish candle confirmation: one means up and zero means down
   if(rates[1].open < rates[1].close)
     {
      if(rates[3].close >=myMovingAverageArray_lowPer_D[1] || rates[3].close >=myMovingAverageArray_highPer_D[1])
        {
         BullishCandleStatus_D = 1;
         //BearishCandleStatus = -1;"
        }

     }
// bearish candle confirmation

   if(rates[1].open > rates[1].close)
     {
      if(rates[3].close <=myMovingAverageArray_lowPer_D[1] || rates[3].close <=myMovingAverageArray_highPer_D[1])
        {
         //BullishCandleStatus = -1;
         BearishCandleStatus_D = 0;
        }
     }

// candleStick Type:
//going up candles
   if(Dailyrates[1].open < Dailyrates[1].close)
     {
      CandleStickStatus_D = 1;
      if(ExtColor_D[1] ==1.0 || ExtColor_D[1] ==6.0)
        {
         CandleStickStatus_D = 1;
        }
      // indecision candle
      //if(ExtColor[1] ==3.0)
      //  {
      //   CandleStickStatus = 0;
      //  }

     }
   if(ExtColor_D[1] ==2.0 || ExtColor_D[1] ==5.0)
     {
      if(theAngleResi_D < 0)
        {
         CandleStickStatus_D = 1;
        }
     }
//going down candles
   if(Dailyrates[1].open > Dailyrates[1].close)
     {
      CandleStickStatus_D = 0;
      if(ExtColor_D[1] ==1.0 || ExtColor_D[1] ==6.0)
        {
         CandleStickStatus_D = 0;
        }
      // indecision candle
      //if(ExtColor[1] ==3.0)
      //  {
      //   CandleStickStatus = 1;
      //  }

     }
   if(ExtColor_D[1] ==2.0 || ExtColor_D[1] ==4.0)
     {
      if(theAngleSupp_D > 0)
        {
         CandleStickStatus_D = 0;
        }
     }

///           Candle forming above/below MA and Price Action Definition  Daily   ///
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CandleSticks_Patterns_Work()
  {

// Results: DNL and UPL seem to have the important hand. I think they might be helpful for defining a good SL
// jUST make sure you're using Higher TimeFrame point prices at the closing of candle under the DNL oR UPL price
   CopyBuffer(indicator_handlePatternChart,2,0,2,checkTruthGetPointsBuffer);

   if(upArrow[1] >0)
     {
      checkTruthGetPointsBuffer[1]=1.0;
     }
   else
      if(downArrow[1]>0)
        {
         checkTruthGetPointsBuffer[1]=0.0;
        }
      else
        {
         ArrayInitialize(checkTruthGetPointsBuffer,checkTruthGetPointsBuffer[1]);
        }
  }



//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   InitializeSupport_ResistanceLines();

//  Wait for beginning of a new bar:
   if(CheckNewBar()==1)
     {
      TrendLinesFunction();
      DailyTrendLinesFunction();

      int highestCandle;
      int lowestCandle;
      int MA_handle;
      double trendMA[];
      double MA[];
      int MA_handle2;
      double MA2[];
      double Low[];
      int ATR_handle;
      double ATR[];


      initializeArrays();


      GeneralBufferCopying();

      Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);




      // High, Low, Close, Rates Arrays Initialization.

      CopyClose(Symbol(),getPeriod,0,2,close);
      CopyHigh(Symbol(),getPeriod,0,10,high);
      CopyLow(Symbol(),getPeriod,0,10,low);

      ArraySetAsSeries(rates,true);
      CopyRates(Symbol(),getPeriod,0,Bars(Symbol(),getPeriod),rates);
      ArraySetAsSeries(Dailyrates,true);
      CopyRates(Symbol(),PERIOD_D1,0,Bars(Symbol(),PERIOD_D1),Dailyrates);

      highestCandle = ArrayMaximum(high);
      CANDLE_STRUCTURE cand1;
      RecognizeCandle(Symbol(),getPeriod,rates[0].time,8,cand1);
      RecognizeCandle(Symbol(),getPeriod,rates[0].time,6,candleType);



      //Print("Verifying if candleType works - Color: "+ExtColor[1]+" "+candleType.high + " "+candleType.low);
      CandleSticks_Patterns_Work();










      //Comment("Pattern Or Not: "+checkTruthGetPointsBuffer[1]);

      //"The support Angle is: "+ theAngleSupp + " the resistance angle is: "+theAngleResi
      //Print("Pattern Or Not: "+checkTruthGetPointsBuffer[1]);

      // Psychological Key Levels
      customRounding(rates[1].close);




      MA_Work();


      CandleType_Work();


      SUPP_RES_Work();



      //Print("Supportdata: "+support_Data[1]+ " ResistanceData: "+resistance_Data[1]);
      //Print("SuppAngle: "+theAngleSupp_D_2+" ResiAngle: "+theAngleResi_D_2 +" pos open: "+PositionGetDouble(POSITION_PRICE_OPEN));
      //Print("x-Array: "+x_arrayCycle[1] + " suupY "+y_arrayCycleSupp[1] + " resY "+y_arrayCycleResi[1]);
      
      // Fulfilled :
      // Trendline Status - Moving Average Stat- Suppport Line Stat - Resistance Line Stat - KeyLevel1,KeyLevel2 - Bullish Candle Status,Bearish Candle Status -
      // CandleStickType(ExtColor - Price Action) - Break Of Structure - Support/Resistance level Zone - StopLoss,TakeProfit - Gold Moving Average Status //
      getPointsGeneral(checkTruthGetPointsBuffer[1],MA_Cross_8_14_P,theAngleSupp,theAngleResi,theAngleSupp_2,theAngleResi_2,
                       dcs_up,dcs_low,BullishCandleStatus,BearishCandleStatus,
                       CandleStickStatus,BreakStrStatus,EnteringZone[1],SuppResTestArray,
                       SuppResTestArray_2,goldenMAStatus,MA_Cross_14_32_P,CandleStickIndecisionStatus,BufferColors[1],
                       MA_Cross_8_14_P_Daily,theAngleSupp_D,theAngleResi_D,theAngleSupp_D_2,theAngleResi_D_2,
                       BullishCandleStatus_D,BearishCandleStatus_D,CandleStickStatus_D,BreakStrStatus_D,goldenMAStatus_D,MA_Cross_14_32_P_Daily);
      
      //Print("Trend Range Color Buffer[1]: "+BufferColors[1] + " bufferMAX: "+BufferMax[1] + " FLAT: "+BufferFlat[1]);
      //Print("Buffer max[2]: "+BufferMax[2] +" buffMax[3]: "+BufferMax[3]);
      //Print("ExtCOLOR on Daily: "+ExtColor_D[1] + " EXTCOLOR on Normal: "+ExtColor[1]);

     } // End of Checking One Candle Formation



  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateAngleResi(int x1, int x2, double y1, double y2)
  {
// Variables
   double resultPix_PriceY, resultPix_BarsX, resultPix_PriceY_2,  resultPix_BarsX_2;
   double angleLongUp;
   double hypothenuse;
   double y_over_hypo;
   double angle,slope;



//  *********** Convert price differences into chart pixels coordinates .  **************************  //

// X-Y axis conversion of Point 1 //

   resultPix_PriceY = getPrice_Pixel_Conversion(y1);

   resultPix_BarsX = getTime_Pixel_Conversion(x1);

// X-Y axis conversion of Point 2 //

   resultPix_PriceY_2 = getPrice_Pixel_Conversion(y2);

   resultPix_BarsX_2 = getTime_Pixel_Conversion(x2);
   if(resultPix_PriceY == 1001 || resultPix_BarsX == 1001 || resultPix_PriceY == 1001 || resultPix_BarsX_2 == 1001)
     {
      // if there are no charts visible
      if(y2<y1)
        {
         // random number. It can be any positive number.
         return 11111;
        }
      else
        {
         // random number. It can be any negative number.
         return -11111;
        }
     }
   else
     {
      //Print("result Pix_PriceY_2: "+resultPix_PriceY_2 + " "+resultPix_BarsX_2 + " "+resultPix_PriceY);

      hypothenuse = MathSqrt(MathPow((resultPix_BarsX_2 - resultPix_BarsX),2) + MathPow((resultPix_PriceY_2 - resultPix_PriceY),2)) ;
      if(hypothenuse==0)
        {
         angle = 0;
         y_over_hypo = 0;
        }
      else
        {
         y_over_hypo = MathAbs(MathRound((resultPix_PriceY_2 - resultPix_PriceY))/((double)hypothenuse));
         angle = (asin(y_over_hypo)*180/M_PI) ;

        }
      if(angle == NULL)
        {
         //Print("It is nothing !!");
        }
      //if(y_over_hypo >=1)
      //  {
      //   return 0;
      //  }
      //else
      if(y1>y2)
        {
         return angle;
         //Print("Up Up Up Trend Boss ???");
        }
      else

        {
         return -angle;
         //Print("Down Down Down Trend Boss ?");
        }


      //Print("resultPix_BarsX_2 - resultPix_BarsX: "
      //      +(resultPix_BarsX_2 - resultPix_BarsX) + "hypoth: "+hypothenuse);
      //Print("y_over_hypo: "+ y_over_hypo);
      //Print("pixelX_1: "+resultPix_BarsX + " pixelY_1: "+resultPix_PriceY
      //+" pixelX_2: "+resultPix_BarsX_2 + " pixelY_2: "+resultPix_PriceY_2);}


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateAngleSupp(int x1, int x2, double y1, double y2)
  {
// Variables
   double resultPix_PriceY, resultPix_BarsX, resultPix_PriceY_2,  resultPix_BarsX_2;
   double angleLongUp;
   double hypothenuse;
   double y_over_hypo;
   double angle,slope;



//  *********** Convert price differences into chart pixels coordinates .  **************************  //

// X-Y axis conversion of Point 1 //

   resultPix_PriceY = getPrice_Pixel_Conversion(y1);

   resultPix_BarsX = getTime_Pixel_Conversion(x1);

// X-Y axis conversion of Point 2 //

   resultPix_PriceY_2 = getPrice_Pixel_Conversion(y2);

   resultPix_BarsX_2 = getTime_Pixel_Conversion(x2);

   if(resultPix_PriceY == 1001 || resultPix_BarsX == 1001 || resultPix_PriceY == 1001 || resultPix_BarsX_2 == 1001)
     {
      // if there are no charts visible
      if(y2<y1)
        {
         // random number. It can be any positive number.
         return 11111;
        }
      else
        {
         // random number. It can be any negative number.
         return -11111;
        }
     }
   else
     {
      hypothenuse = MathSqrt(MathPow((resultPix_BarsX_2 - resultPix_BarsX),2) + MathPow((resultPix_PriceY_2 - resultPix_PriceY),2)) ;
      if(hypothenuse==0)
        {
         angle = 0;
         y_over_hypo = 0;
        }
      else
        {
         y_over_hypo = MathAbs(MathRound((resultPix_PriceY_2 - resultPix_PriceY))/((double)hypothenuse));
         angle = (asin(y_over_hypo)*180/M_PI) ;

        }
      if(angle == NULL)
        {
         //Print("It is nothing !!");
        }
      //Print("resultPix_Pice_2 -> resultPix_BarsY: " +resultPix_PriceY_2 +" "+ resultPix_PriceY + "hypoth: "+hypothenuse);
      //if(y_over_hypo >=1)
      //  {
      //   return 0;
      //  }
      //else
      if(y1>y2)
        {
         return angle;
         //Print("Up Up Up Trend Boss ???");
        }
      else

        {
         return -angle;
         //Print("Down Down Down Trend Boss ?");
        }



      //Print("y_over_hypo: "+ y_over_hypo);
      //Print("pixelX_1: "+resultPix_BarsX + " pixelY_1: "+resultPix_PriceY
      //+" pixelX_2: "+resultPix_BarsX_2 + " pixelY_2: "+resultPix_PriceY_2);
     }


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getTime_Pixel_Conversion(int LowestCand)
  {
   double Max_Min_CHART, ratio_pixel_priceY, resultPix_PriceY,  resultPix_BarsX;
   double ratio_Bars_Pixel;
// If there is no visible chart
   if(ChartGetInteger(_Symbol,CHART_HEIGHT_IN_PIXELS,0) ==0)
     {
      // random number. It represents this error of no chart available. Helps testing with no Visualization
      return 1001;
     }
   else
     {
      // Normal Logic
      if(ChartGetInteger(0,CHART_VISIBLE_BARS,0)==0)
        {
         ratio_Bars_Pixel = 0;
        }
      else
        {
         ratio_Bars_Pixel = (double)107/(double)ChartGetInteger(0,CHART_VISIBLE_BARS,0);
        }
      //Print("visible bars# "+ChartGetInteger(0,CHART_VISIBLE_BARS,0) +"lowestCand" + LowestCand + "ratio bars -pixels " + ratio_Bars_Pixel);

      resultPix_BarsX = (ChartGetInteger(0,CHART_VISIBLE_BARS,0) - LowestCand) * ratio_Bars_Pixel;

      //Print(ChartGetInteger(0,CHART_VISIBLE_BARS,0)+" VISIBLE BARS <<<?>><><><><>><><><> ");
      return resultPix_BarsX;
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getPrimeNumbers() {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPrice_Pixel_Conversion(double price)
  {
   double Max_Min_CHART, ratio_pixel_priceY, resultPix_PriceY,  resultPix_BarsX;
// If there is no visible chart
   if(ChartGetInteger(_Symbol,CHART_HEIGHT_IN_PIXELS,0) ==0)
     {
      // random number. It represents this error of no chart available. Helps testing with no Visualization
      return 1001;
     }
   else
     {
      // Normal Logic
      if(ChartGetDouble(_Symbol,CHART_PRICE_MAX,0) == ChartGetDouble(_Symbol,CHART_PRICE_MIN,0))
        {
         //Max_Min_CHART = 0;
         ratio_pixel_priceY = 0;
        }
      else
        {
         Max_Min_CHART = ChartGetDouble(_Symbol,CHART_PRICE_MAX,0) - ChartGetDouble(_Symbol,CHART_PRICE_MIN,0);
         ratio_pixel_priceY = 106/Max_Min_CHART;
        }


      resultPix_PriceY = ((ChartGetDouble(_Symbol,CHART_PRICE_MAX,0) - price)*ratio_pixel_priceY);
      //Print("Chart maxX man: "+ChartGetDouble(_Symbol,CHART_PRICE_MAX,0)+ " AND MIN: "+ChartGetDouble(_Symbol,CHART_PRICE_MIN,0));
      //Print(ChartGetInteger(_Symbol,CHART_HEIGHT_IN_PIXELS,0) +" pixels HEIGHT coord.. >>>>>>><>>>>><><>><><");
      return resultPix_PriceY;
     }

  }
//+------------------------------------------------------------------+
bool BuySignal(double cand1, double cand2, double cand3, double levK)
  {
   if(cand1 > levK && cand2 > levK && cand3 > levK)
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   return(close[0]<dcs_midd[0])?true:false;
  }
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   return(CopyBuffer(InpInd_Handle1_DonChInd,0,0,2,dcs_up)<=0  ||
          CopyBuffer(InpInd_Handle1_DonChInd,1,0,2,dcs_midd)<=0 ||
          CopyClose(Symbol(),getPeriod,0,2,close)<=0
         )?false:true;
  }
//+------------------------------------------------------------------+
bool GetIndHandle()
  {
   return(true);
  }
//+------------------------------------------------------------------+
int CheckNewBar()
  {
   MqlRates      current_rates[1];
   CopyRates(Symbol(),getPeriod,0,1,current_rates);
   double current_volume = (const)current_rates[0].tick_volume;

   ResetLastError();
   if(CopyRates(Symbol(),getPeriod,0,1,current_rates)!=1)
     {
      //Print("CopyRates copy error, Code = ",GetLastError());
      return(0);
     }

// Only consider updating the OnTick() when the current rate's volume is greater than 50.
//   if(current_volume > 50)
//     {
//      if(current_rates[0].tick_volume>(current_volume + 50))
//        {
//         return(0);
//        }
//     }
//   else
//     {
//
//     }
   if(current_rates[0].tick_volume>1)
     {
      return(0);
     }



   return(1);
  }
//+------------------------------------------------------------------+

input string H=" --- Mode_Settings ---";
input bool Show_00_50_Levels=false;
input bool Show_20_80_Levels=true;
input color Level_00_Color=clrLime;
input color Level_50_Color=clrGray;
input color Level_20_Color=clrRed;
input color Level_80_Color=clrGreen;

double dXPoint=1;
double Div=0;
double i=0;
double HighPrice= 0;
double LowPrice = 0;
int iDigits;
double level_00Array[140];
double level_50Array[140];
double level_20Array[140];

double stopLoss;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int createKeyLevels(int time, double price0High, double price0Low)
  {

   HighPrice= MathRound((ChartGetDouble(_Symbol,CHART_PRICE_MAX,0)+1)*Div);
   LowPrice = MathRound((ChartGetDouble(_Symbol,CHART_PRICE_MIN,0)-1)*Div);
   double level_80Array[20];
   if(Show_00_50_Levels)
     {

      for(i=LowPrice; i<=HighPrice; i++)
        {
         if(MathMod(i,5)==0.0)
           {
            string name="RoundPrice "+DoubleToString(i,0);
            if(ObjectFind(0,name)!=0)
              {
               ObjectCreate(0,name,OBJ_HLINE,0,time,i/Div);
               ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
               if(MathMod(i,10)==0.0)
                 {
                  ObjectSetInteger(0,name,OBJPROP_COLOR,Level_00_Color);
                  level_00Array[0]  = ObjectGetDouble(_Symbol,name,OBJPROP_PRICE,0);
                 }

               else
                 {
                  ObjectSetInteger(0,name,OBJPROP_COLOR,Level_50_Color);
                  level_50Array[0]  = ObjectGetDouble(_Symbol,name,OBJPROP_PRICE,0);
                 }

              }
           }
        }

     }

   if(Show_20_80_Levels)
     {

      for(i=LowPrice; i<=HighPrice; i++)
        {
         if(StringSubstr(DoubleToString(i/Div,iDigits),StringLen(DoubleToString(i/Div,iDigits))-2,2)=="20")
           {
            string name="RoundPrice "+DoubleToString(i,0);
            if(ObjectFind(0,name)!=0)
              {
               ObjectCreate(0,name,OBJ_HLINE,0,time,i/Div);
               ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
               ObjectSetInteger(0,name,OBJPROP_COLOR,Level_20_Color);
               level_20Array[0]  = ObjectGetDouble(_Symbol,name,OBJPROP_PRICE,0);
              }
           }
         if(StringSubstr(DoubleToString(i/Div,iDigits),StringLen(DoubleToString(i/Div,iDigits))-2,2)=="80")
           {
            string name="RoundPrice "+DoubleToString(i,0);
            //            if(ObjectFind(0,name)!=0)
            //              {
            //
            //
            //              }
            ObjectCreate(0,name,OBJ_HLINE,0,time,i/Div);
            ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
            ObjectSetInteger(0,name,OBJPROP_COLOR,Level_80_Color);

            if(ObjectGetDouble(_Symbol,name,OBJPROP_PRICE,0)-1 < price0High && ObjectGetDouble(_Symbol,name,OBJPROP_PRICE,0)-1 > price0Low
              )
              {
               //counting += 1;
               //Print("It is happening");
               //Print("This is from indicator: "+" i: "+i+" "+ObjectGetDouble(_Symbol,name,OBJPROP_PRICE,0));
               //level_80Array[j]  = ObjectGetDouble(_Symbol,name,OBJPROP_PRICE,0);
               //stopLoss = getMinimumKeyLevel(level_80Array[0]);
               //Print("ARRyMax: "+ArrayMaximum(level_80Array));
              }
            //Print("Let us compare them pls: //MarkPattern vs price "+(ObjectGetDouble(_Symbol,name,OBJPROP_PRICE,0)-1) + " "+price0High + " "+price0Low);
           }
        }
     }
//Print("The counting from method: "+ counting);
   return 0;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
double getMinimumKeyLevel(double minKeyLev) {return minKeyLev;}
//+------------------------------------------------------------------+

double power, ratio;
input uint RoundDigits=4;                          //nuber of zeros in the digits
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void customRounding(double Price)
  {
   power=MathPow(10,RoundDigits);
   ratio=_Point*power;
   double Res=MathFloor(Price/ratio);

//Print(" The price breakthrough the level "+DoubleToString(Res*ratio,_Digits)+"!");
//Print("Res * ratio: "+ Res +" *" + ratio + ": "+(Res*ratio));
   createPsychologicalKeyLevels(Res,ratio);
  }
//+------------------------------------------------------------------+
double keyLevelsMaj[4];
double keyLevelsMid[4];
void createPsychologicalKeyLevels(double Res, double ratio)
  {
   ObjectDelete(_Symbol,"4");
   ObjectDelete(_Symbol,"3");
   ObjectDelete(_Symbol,"2");
   ObjectDelete(_Symbol,"1");
   keyLevelsMaj[0] = (Res - 1)*ratio;
   keyLevelsMaj[1] = (Res)*ratio;
   keyLevelsMaj[2] = (Res + 1)*ratio;
   keyLevelsMaj[3] = (Res + 2)*ratio;

// Between 0 and 1
   keyLevelsMid[0] = (keyLevelsMaj[0] + keyLevelsMaj[1])/2;
// Between 1 and 2
   keyLevelsMid[1] = (keyLevelsMaj[1] + keyLevelsMaj[2])/2;
// Between 2 and 3
   keyLevelsMid[2] = (keyLevelsMaj[2] + keyLevelsMaj[3])/2;

   ObjectCreate(Symbol(),"4",OBJ_HLINE,0,1,keyLevelsMaj[0]);
   ObjectCreate(Symbol(),"3",OBJ_HLINE,0,1,keyLevelsMaj[1]);
   ObjectCreate(Symbol(),"2",OBJ_HLINE,0,1,keyLevelsMaj[2]);
   ObjectCreate(Symbol(),"1",OBJ_HLINE,0,1,keyLevelsMaj[3]);

//ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,"1",OBJPROP_COLOR,Red);
   ObjectSetInteger(0,"2",OBJPROP_COLOR,Red);

   ObjectCreate(Symbol(),"0 - 1",OBJ_HLINE,0,1,keyLevelsMid[0]);
   ObjectCreate(Symbol(),"1 - 2",OBJ_HLINE,0,1,keyLevelsMid[1]);
   ObjectCreate(Symbol(),"2 - 3",OBJ_HLINE,0,1,keyLevelsMid[2]);


//ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,"0 - 1",OBJPROP_COLOR,White);
   ObjectSetInteger(0,"1 - 2",OBJPROP_COLOR,White);
   ObjectSetInteger(0,"2 - 3",OBJPROP_COLOR,White);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double stopLossBuyPos(double firstKey, double secKey, double chandExit,double currPrice)
  {
   double BuystopLoss;
   int stL = (firstKey + secKey)/2;
   BuystopLoss = (firstKey + secKey)/2;
   if(
      chandExit < 2 *currPrice)
     {
      stL = chandExit;
      //Print("Next: .....  "+"UpdBuffer[1]: "+UpdBuffer1[1] + " DndBuffer1[1]: "
      //      +DndBuffer1[1]+" UpdBuffer2[1]: "
      //      +UpdBuffer2[1] + " DndBuffer2[1]: "
      //      +DndBuffer2[1]);
     }
   return BuystopLoss;
  }
//+------------------------------------------------------------------+
double takeProBuyPos(double AskPrice, double stopLossBuy)
  {
   double takeProf = (AskPrice - stopLossBuy)*3;
   return (takeProf + AskPrice);

  }
//+------------------------------------------------------------------+
double takeProSellPos(double BidPrice, double stopLossSell)
  {
   double takeProf = (stopLossSell - BidPrice)*3;
   return (BidPrice + takeProf);

  }
//+------------------------------------------------------------------+
void stopLossNew() {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void takeProfitNew() {}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initializeArrays() //counting +=1;
  {
////Print("Buy");
//   MA_handle = iMA(_Symbol, _Period, 6, 0, MODE_EMA, PRICE_CLOSE);
//
//   MA_handle2 = iMA(_Symbol, _Period, 14, 0, MODE_EMA, PRICE_CLOSE);
//   int movingAverageTrend = iMA(_Symbol,_Period,8,0,MODE_SMA,PRICE_CLOSE);
//   ArraySetAsSeries(MA,true);
//   ArraySetAsSeries(MA2,true);
//   ArraySetAsSeries(ATR,true);
//   ArraySetAsSeries(trendMA,true);
//   CopyBuffer(MA_handle,0,0,3,MA);
//   CopyBuffer(MA_handle2,0,0,3,MA2);
//   CopyBuffer(movingAverageTrend,0,0,3,trendMA);

//ArrayInitialize(dcs_up,0.0);
//ArrayInitialize(dcs_low,0.0);
//ArraySetAsSeries(checkTruthGetPointsBuffer,true);
   ArraySetAsSeries(BufferMax,true);
   ArraySetAsSeries(BufferFlat, true);
   ArraySetAsSeries(BufferHist,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(EnteringZone,true);
   ArraySetAsSeries(upArrow,true);
   ArraySetAsSeries(downArrow,true);
   ArraySetAsSeries(ExtColor,true);
   ArraySetAsSeries(ExtColor_D,true);
   ArraySetAsSeries(dcs_up,true);
   ArraySetAsSeries(dcs_midd,true);
   ArraySetAsSeries(dcs_low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(support_Data,true);
   ArraySetAsSeries(resistance_Data,true);
   ArraySetAsSeries(BufferBKR,true);
   ArraySetAsSeries(BufferTKR,true);
// For Chandelier Exit
   ArraySetAsSeries(UplBuffer1,true);
   ArraySetAsSeries(UplBuffer2,true);
   ArraySetAsSeries(DnlBuffer1,true);
   ArraySetAsSeries(DnlBuffer2,true);
   ArraySetAsSeries(UpdBuffer1,true);
   ArraySetAsSeries(UpdBuffer2,true);
   ArraySetAsSeries(DndBuffer1,true);
   ArraySetAsSeries(DndBuffer2,true);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TraillingStopLoss(double EntryPrice, double NewStopLoss) //--- trailing position
  {
// desired stop loss
//double SL = NormalizeDouble(Bid + 150 * _Point,_Digits);
   for(i=PositionsTotal(); i>=0; i--)
     {
      if(Symbol()==PositionGetSymbol(i))
        {
         // get ticket number
         ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
         //// get current stop loss
         //double currentStopLoss = PositionGetDouble(POSITION_SL);

         // Modify Stpo loss
         trade.PositionModify(PositionTicket,NewStopLoss,PositionGetDouble(POSITION_TP));
        }
     }
  }
//+------------------------------------------------------------------+

//int movingAverageSignal_Daily, double trendSignalBelow_Daily,
//                        double trendSignalAbove_Daily,double trendSignalBelow__Daily_2,
//                        double trendSignalAbove__Daily_2, int bullCandleSignal_Daily, int bearCandleSignal_Daily,
//                        int candStickTypeSignal_Daily,int goldenMACandleSignal_Daily, int goldenMASignalCrossing_Daily
int DailyConfluenceTeam[15];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getDailyConfluence()
  {

  }
//+------------------------------------------------------------------+

bool ENTRY_1_ALLOWED =false;
bool ENTRY_2_ALLOWED = false;
bool ENTRY_3_ALLOWED = true;
int BlueTeamPoints = 0;
int RedTeamPoints = 0;
bool MACheck = false;
bool BreakStrCheck = false;
bool CandTypeCheck = false;
int ConfluenceTeam[20];
bool buyCheck = true;
bool sellCheck= true;
int goldenMACounter = 0;
int goldenMACounter_2 = 0;
bool releaseFastSystem = false;
bool release_P_System = true;
int release_P_SystemCounter = 0;
int positionType;

int yesCounting;
int noCounting;
int confluence_10_Counter=0;
int earlySLCount = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_ORDER_REASON reason = 0;
//MqlRates lowerRates[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getPointsGeneral(double candPatternSignal, int movingAverageSignal, double trendSignalBelow,
                      double trendSignalAbove,double trendSignalBelow_2,
                      double trendSignalAbove_2, double &limitUpperDoncInd[],double &limitLowerDoncInd[],
                      int bullCandleSignal, int bearCandleSignal, int candStickTypeSignal, int BreakOfStructureSignal,double zoneEnterSignal,
                      double &suppResPrice[], double &suppResPrice_2[], int goldenMACandleSignal,
                      int goldenMASignalCrossing, int candleIndecisionSignal, int consolidationSignal,

                      int movingAverageSignal_Daily, double trendSignalBelow_Daily,
                      double trendSignalAbove_Daily,double trendSignalBelow_Daily_2,
                      double trendSignalAbove_Daily_2, int bullCandleSignal_Daily, int bearCandleSignal_Daily,
                      int candStickTypeSignal_Daily, int BreakOfStructureSignal_Daily,int goldenMACandleSignal_Daily,
                      int goldenMASignalCrossing_Daily)
  {
//         *****    Confluences for Daily Timeframe       ****      //
// TrendLine Support
   if(trendSignalBelow_Daily < 0)
     {
      DailyConfluenceTeam[0] = 0;
      //RedTeamPoints +=1;
     }

   if(trendSignalBelow_Daily > 0)
     {
      DailyConfluenceTeam[0]=1;
      //BlueTeamPoints +=1;
     }

   if(trendSignalBelow_Daily == 0)
     {
      DailyConfluenceTeam[0]= -1;
     }

// TrendLine Resistance
   if(trendSignalAbove_Daily < 0)
     {
      DailyConfluenceTeam[1] = 0;
      //RedTeamPoints +=1;
     }

   if(trendSignalAbove_Daily > 0)
     {
      DailyConfluenceTeam[1]=1;
      //BlueTeamPoints +=1;
     }
   if(trendSignalAbove_Daily == 0)
     {
      DailyConfluenceTeam[1]= -1;
     }


// Moving Average CrossOver
   if(movingAverageSignal_Daily == 0)
     {
      DailyConfluenceTeam[2] = 0;
      //Print("Crossover Down");

     }

   if(movingAverageSignal_Daily == 1)
     {
      DailyConfluenceTeam[2] = 1;
      //Print("Crossover Up");
     }

// bullish candle forms above MA - bearish candle forms below MA

   if(bullCandleSignal_Daily == 1)
     {
      DailyConfluenceTeam[3] = 1;
     }
   if(bearCandleSignal_Daily == 0)
     {
      DailyConfluenceTeam[3] = 0;
     }
// Candlestick Type - Price Action
   if(candStickTypeSignal_Daily == 1)
     {
      DailyConfluenceTeam[4] = 1;
     }
   if(candStickTypeSignal_Daily == 0)
     {
      DailyConfluenceTeam[4] = 0;
     }


// Golden Moving Average with Candles forming above/below it
   if(goldenMACandleSignal_Daily == 0)
     {
      DailyConfluenceTeam[5] = 0;
      //goldenMACounter += 1;
     }
   if(goldenMACandleSignal_Daily == 1)
     {
      DailyConfluenceTeam[5] = 1;
      //goldenMACounter_2 += 1;
     }


// Golden Moving Average Crossover Signal
   if(goldenMASignalCrossing_Daily == 1)
     {
      DailyConfluenceTeam[6] = 1;
      //Print("Croosssssed Uppppppppppppppppppppp");
     }
   if(goldenMASignalCrossing_Daily == 0)
     {
      DailyConfluenceTeam[6] = 0;
      //Print("Croosssssed Downnnnnnnnnnnnnnnn");
     }
// Break Of Structure of TrendLines: The Lower Period
   if(BreakOfStructureSignal_Daily == 0)
     {
      DailyConfluenceTeam[7] =0;
     }
   else
      if(BreakOfStructureSignal_Daily == 1)
        {
         DailyConfluenceTeam[7] = 1;
        }
      else
        {
         DailyConfluenceTeam[7]= -1;
        }
   Print("Daily Support: "+support_Data_D[0] + " Daily Resis: "+resistance_Data_D[0]);
   Print("rates[1].close: "+rates[1].close);

// TrendLine Support number 2: Higher Period
   if(trendSignalBelow_Daily_2 < 0)
     {
      DailyConfluenceTeam[8] = 0;
      //RedTeamPoints +=1;
     }

   if(trendSignalBelow_Daily_2 > 0)
     {
      DailyConfluenceTeam[8]=1;
      //BlueTeamPoints +=1;
     }

   if(trendSignalBelow_Daily_2 == 0)
     {
      DailyConfluenceTeam[8]= -1;
     }

// TrendLine Resistance number 2: Higher Period
   if(trendSignalAbove_Daily_2 < 0)
     {
      DailyConfluenceTeam[9] = 0;
      //RedTeamPoints +=1;
     }

   if(trendSignalAbove_Daily_2 > 0)
     {
      DailyConfluenceTeam[9]= 1;
      //BlueTeamPoints +=1;
     }
   if(trendSignalAbove_Daily_2 == 0)
     {
      DailyConfluenceTeam[9]= -1;
     }
// Candle being formed above/below of TrendLines for Higher Period:
   if(rates[1].close < support_Data_D_2[1])
     {
      DailyConfluenceTeam[10] =0;
     }
   else
      if(rates[2].close > resistance_Data_D_2[1])
        {
         DailyConfluenceTeam[10] = 1;
        }
      else
        {
         DailyConfluenceTeam[10]= -1;
        }
// Break Of Structure of TrendLines: These are from mixed Trends (Long and Short)
   if(DailyConfluenceTeam[10] == 0 && DailyConfluenceTeam[1]==0 && DailyConfluenceTeam[8]==1)
     {
      DailyConfluenceTeam[11] =0;
     }
   else
      if(DailyConfluenceTeam[10] == 1 && DailyConfluenceTeam[0]==1 && DailyConfluenceTeam[9]==0)
        {
         DailyConfluenceTeam[11] = 1;
        }
      else
        {
         DailyConfluenceTeam[11]= -1;
        }
// Safety Check Confluence: Not trading unless close to a Support/Resistance Trendlines.
   if(MathAbs(Dailyrates[1].close - support_Data_D[1])*MathPow(10,_Digits)<= 500
      || MathAbs(Dailyrates[1].low - support_Data_D[1])*MathPow(10,_Digits)<= 200
      || MathAbs(Dailyrates[1].close - support_Data_D_2[1])*MathPow(10,_Digits)<= 500
      || MathAbs(Dailyrates[1].low - support_Data_D_2[1])*MathPow(10,_Digits)<= 200)
     {
      DailyConfluenceTeam[12] = 1;
     }
   else
      if(MathAbs(Dailyrates[1].close - resistance_Data_D[1])*MathPow(10,_Digits)<= 500
         || MathAbs(Dailyrates[1].high - resistance_Data_D[1])*MathPow(10,_Digits)<= 200
         || MathAbs(Dailyrates[1].close - resistance_Data_D_2[1])*MathPow(10,_Digits)<= 500
         || MathAbs(Dailyrates[1].high - resistance_Data_D_2[1])*MathPow(10,_Digits)<= 200)
        {
         DailyConfluenceTeam[12] = 0;
        }
      else
        {
         DailyConfluenceTeam[12] = -1;
        }
// Let's put everything together and see our results

//Comment("Confluence Results: "+DailyConfluenceTeam[0]+" "+DailyConfluenceTeam[1]+" "+DailyConfluenceTeam[2]+" "+DailyConfluenceTeam[3]
//        +" "+DailyConfluenceTeam[4] +" "+DailyConfluenceTeam[5] +" "+DailyConfluenceTeam[6] + DailyConfluenceTeam[7]+" "
//        +DailyConfluenceTeam[8]+" "+DailyConfluenceTeam[9]+" "+DailyConfluenceTeam[10]+" "+DailyConfluenceTeam[11]);

//                      ^^^     *****    Confluences for Daily Timeframe       *****    ^^^                       //

// TrendLine Support
   if(trendSignalBelow < 0)
     {
      ConfluenceTeam[0] = 0;
      //RedTeamPoints +=1;
     }

   if(trendSignalBelow > 0)
     {
      ConfluenceTeam[0]=1;
      //BlueTeamPoints +=1;
     }

   if(trendSignalBelow == 0)
     {
      ConfluenceTeam[0]= -1;
     }

// TrendLine Resistance
   if(trendSignalAbove < 0)
     {
      ConfluenceTeam[1] = 0;
      //RedTeamPoints +=1;
     }

   if(trendSignalAbove > 0)
     {
      ConfluenceTeam[1]=1;
      //BlueTeamPoints +=1;
     }
   if(trendSignalAbove == 0)
     {
      ConfluenceTeam[1]= -1;
     }


// Moving Average
   if(movingAverageSignal == 0)
     {
      ConfluenceTeam[2] = 0;
      //Print("Crossover Down");

     }

   if(movingAverageSignal == 1)
     {
      ConfluenceTeam[2] = 1;
      //Print("Crossover Up");
     }

// bullish candle forms above MA - bearish candle forms below MA

   if(bullCandleSignal == 1)
     {
      ConfluenceTeam[3] = 1;
     }
   if(bearCandleSignal == 0)
     {
      ConfluenceTeam[3] = 0;
     }

// Candlestick pattern
   if(candPatternSignal == 1)
     {
      ConfluenceTeam[4] = 1;
     }
   if(candPatternSignal == 0)
     {
      ConfluenceTeam[4] = 0;
     }
// Candlestick Type - Price Action
   if(candStickTypeSignal == 1)
     {
      ConfluenceTeam[5] = 1;
     }
   if(candStickTypeSignal == 0)
     {
      ConfluenceTeam[5] = 0;
     }


// Golden Moving Average with Candles forming above/below it
   if(goldenMACandleSignal == 0)
     {
      ConfluenceTeam[7] = 0;
      goldenMACounter += 1;
     }
   if(goldenMACandleSignal == 1)
     {
      ConfluenceTeam[7] = 1;
      goldenMACounter_2 += 1;
     }


// Golden Moving Average Crossover Signal
   if(goldenMASignalCrossing == 1)
     {
      ConfluenceTeam[8] = 1;
      //Print("Croosssssed Uppppppppppppppppppppp");
     }
   if(goldenMASignalCrossing == 0)
     {
      ConfluenceTeam[8] = 0;
      //Print("Croosssssed Downnnnnnnnnnnnnnnn");
     }

// Confluence 7 and 8 working together for goldenMA counters. Plus normal moving average candle formation //

   if(goldenMACandleSignal == 0 && rates[1].high <= goldenMovingAverageArray[1])
     {
      // if candle forms below golden MA and its highest point price is below or equal to the MA price, then
      goldenMACounter += 1;
      if(goldenMACandleSignal ==0 && MathAbs(rates[1].high - goldenMovingAverageArray[1]) <=140*_Point)
        {
         // if candle forms below golden MA and the difference btwn the current price-high and the MA price is below 14 pips,
         // then:
         goldenMACounter =0;
        }
     }
   else
      if(goldenMACandleSignal ==0 && MathAbs(rates[1].high - goldenMovingAverageArray[1]) <=140*_Point)
        {
         // if candle forms below golden MA and the difference btwn the current price-high and the MA price is below 14 pips,
         // then:
         goldenMACounter =0;
        }
      else
        {
         goldenMACounter = 0;
        }

   if(goldenMACandleSignal == 1 && rates[1].low >= goldenMovingAverageArray[1])
     {
      // if candle forms above golden MA and its lowest point price is above or equal to the MA price, then
      goldenMACounter_2 += 1;
      if(goldenMACandleSignal ==1 && MathAbs(rates[1].low - goldenMovingAverageArray[1]) <=140*_Point)
        {
         // if candle forms above golden MA and the difference btwn the current price-low and the MA price is below 14 pips,
         // then:
         goldenMACounter_2 = 0;
        }
     }
   else
      if(goldenMACandleSignal ==1 && MathAbs(rates[1].low - goldenMovingAverageArray[1]) <=140*_Point)
        {
         // if candle forms above golden MA and the difference btwn the current price-low and the MA price is below 14 pips,
         // then:
         goldenMACounter_2 = 0;
        }
      else
        {
         goldenMACounter_2 = 0;
        }


// This a re-entry checking point each time the protection SL is reached too soon. This will
// form Confluence #10.
   if(changedSL == true && triggeredSLEarly == 1)
     {
      ConfluenceTeam[10] = 1;
      //Print("Triggered by SL change of 3 pips ???????");
      goldenMACounter = 0;
      goldenMACounter_2 = 0;
     }
   else
     {
      ConfluenceTeam[10] = -1;
     }

   if(ConfluenceTeam[10] == 1)
     {
      confluence_10_Counter +=1;
      if(confluence_10_Counter >=5)
        {
         changedSL = false;
        }
     }
   if(ConfluenceTeam[10] == -1)
     {
      confluence_10_Counter +=1;
      if(confluence_10_Counter >=5)
        {
         changedSL = false;
        }
     }
//Print("confluence_10_Counter " + confluence_10_Counter);

// Break Of Structure of TrendLines
   if(BreakOfStructureSignal == 0 || ConfluenceTeam[10] == 1)
     {
      ConfluenceTeam[6] =0;
     }
   else
      if(BreakOfStructureSignal == 1 || ConfluenceTeam[10] == 1)
        {
         ConfluenceTeam[6] = 1;
        }
      else
        {
         ConfluenceTeam[6]= -1;
        }


// Confluence 7 and 8 working together for goldenMA counters. Plus normal moving average candle formation  //

// Golden Moving Average Safe Entries Check Confluence
   if(goldenMACounter >=2 || goldenMACounter_2 >= 2)
     {
      // not good entry
      ConfluenceTeam[9] = -1;
     }
   else
     {
      // probably good entry
      ConfluenceTeam[9] = 1;
     }

// Safe Entries Check Confluence: The trend Lines Angle
   if(MathAbs(trendSignalBelow) <= 13 || MathAbs(trendSignalAbove) <= 13)
     {
      ConfluenceTeam[11] = -1;
     }
   else
     {
      ConfluenceTeam[11] = 1;
     }
// Safe Entries Check Confluence: Consolidation with candleStick
   if(candleIndecisionSignal == 1)
     {
      ConfluenceTeam[12] = 1;
     }
   if(candleIndecisionSignal == -1)
     {
      ConfluenceTeam[12] = -1;
     }
// Safe Entries Check Confluence: Consolidation with DoncInd Middle
   if(
      (rates[1].high >= resistance_Data[1])
      || (rates[1].low <= support_Data[1]))
     {

      // if break of structure is okay with price-MA formation then great. Break of Structure
      // to the upward direction with golden MA price above it

      if(ConfluenceTeam[7] ==1 && ConfluenceTeam[6] ==1)
        {
         ConfluenceTeam[13]=1;
        }// if break of structure is okay with price-MA formation then great. Break of Structure
      // to the downward direction with golden MA price forming below it
      else
         if(ConfluenceTeam[7] ==0 && ConfluenceTeam[6] ==0)
           {
            ConfluenceTeam[13]=1;
           }
         else
           {
            ConfluenceTeam[13] = -1;
           }

     }
   else
     {
      ConfluenceTeam[13] = 1;
     }
//// Safe Entries Check Confluence: Consolidation - Possible Ranging MARKET Indicator
   EntryConsolidationPattern();
   ExhaustionPattern();
   MajorKeyLevelsZone(suppResPrice_2);
// Confluence checks if there is any consolidation: Safety Check Confluence
   if(ConsolidationPatternStart == true)
     {
      ConfluenceTeam[14] = 1;
     }
   else
     {
      ConfluenceTeam[14] = -1;
     }
//                           >>>  ConfluenceTeam[15]  >>>                          //
// Confluence checks if at which Major Key level we're at


// Third Zone: with the half of Donc Ind
   if((dcs_midd[1] + 0.15*MathAbs(dcs_up[1] - dcs_midd[1])) >= rates[1].low && (dcs_midd[1]) <= rates[1].low)
     {
      // facing up.
      if(ConsolidationPatternStart == false)
        {
         Print("From DonchIndLevels Maj Up");
         ConfluenceTeam[15] = 1;
        }

     }

   if((dcs_midd[1] - 0.15*MathAbs(dcs_low[1] - dcs_midd[1])) <= rates[1].high && (dcs_midd[1]) >= rates[1].high)
     {
      // facing down.
      if(ConsolidationPatternStart == false)
        {
         Print("From DonchIndLevels Maj Down");
         ConfluenceTeam[15] = 0;
        }
     }
// Fifth Zone: Psychological Levels
   if(keyLevelsMaj[2] - 0.07*MathAbs(keyLevelsMaj[1] - keyLevelsMaj[2]) <= rates[1].high)
     {
      if(ConsolidationPatternStart == false)
        {
         Print("From Psych Levels Maj [2]");
         ConfluenceTeam[15] = 0;
        }
     }
   if(keyLevelsMaj[1] + 0.07*MathAbs(keyLevelsMaj[1] - keyLevelsMaj[2]) >= rates[1].low)
     {
      if(ConsolidationPatternStart == false)
        {
         Print("From Psych Levels Maj [1]");
         ConfluenceTeam[15] = 1;
        }
     }
// Sixth Zone: Middle Psychological Levels
   if((keyLevelsMid[1] + 0.07*MathAbs(keyLevelsMaj[2] - keyLevelsMid[1])) >= rates[1].low
      && (keyLevelsMid[1]) <= rates[1].low)
     {
      if(ConsolidationPatternStart == false)
        {
         Print("From Psych Levels Mid Down");
         ConfluenceTeam[15] = 1;
        }
     }
   if((keyLevelsMid[1] - 0.07*MathAbs(keyLevelsMaj[1] - keyLevelsMid[1])) <= rates[1].low
      && (keyLevelsMid[1]) >= rates[1].high)
     {
      if(ConsolidationPatternStart == false)
        {
         Print("From Psych Levels Mid Up");
         ConfluenceTeam[15] = 0;
        }
     }
//                            ^^^^ ConfluenceTeam[15]  ^^^                          //






// TrendLine Support number 2: Higher Period
   if(trendSignalBelow_2 < 0)
     {
      ConfluenceTeam[16] = 0;
      //RedTeamPoints +=1;
     }

   if(trendSignalBelow_2 > 0)
     {
      ConfluenceTeam[16]=1;
      //BlueTeamPoints +=1;
     }

   if(trendSignalBelow_2 == 0)
     {
      ConfluenceTeam[16]= -1;
     }

// TrendLine Resistance number 2: Higher Period
   if(trendSignalAbove_2 < 0)
     {
      ConfluenceTeam[17] = 0;
      //RedTeamPoints +=1;
     }

   if(trendSignalAbove_2 > 0)
     {
      ConfluenceTeam[17]= 1;
      //BlueTeamPoints +=1;
     }
   if(trendSignalAbove_2 == 0)
     {
      ConfluenceTeam[17]= -1;
     }
// Candle being formed above/below of TrendLines for Higher Period:
   if(rates[1].close < support_Data_2[1])
     {
      ConfluenceTeam[18] =0;
     }
   else
      if(rates[1].close > resistance_Data_2[1])
        {
         ConfluenceTeam[18] = 1;
        }
      else
        {
         ConfluenceTeam[18]= -1;
        }
// Break Of Structure of TrendLines: These are from mixed Trends (Long and Short)
   if(ConfluenceTeam[18] == 0)
     {
      if(ConfluenceTeam[16]==1 || ConfluenceTeam[16] ==-1)
        {
         if(ConfluenceTeam[1]==0)
           {
            ConfluenceTeam[19] =0;
           }
        }

     }

   else
      if(ConfluenceTeam[18] == 1)
        {
         if(ConfluenceTeam[17]==0 || ConfluenceTeam[17]==-1)
           {
            if(ConfluenceTeam[0]==1)
              {
               ConfluenceTeam[19] = 1;
              }
           }

        }
      else
        {
         ConfluenceTeam[19]= -1;
        }

// Entering ZONE Status
   if(zoneEnterSignal == 1)
     {
      //Print("Too safe");
     }
   else
      if(zoneEnterSignal == -1)
        {
         //Print("Great you can enter");
        }

//Comment("Angle Supp: "+trendSignalBelow+ " Angle Res: "+trendSignalAbove);
   Print("SuppresPrice: "+suppResPrice[3]+" SuppRespRICE_2: "+suppResPrice_2[3]);

// Let's put everything together and see our results

   Comment("Confluence Results: "+ConfluenceTeam[0]+" "+ConfluenceTeam[1]+" "+ConfluenceTeam[2]+" "+ConfluenceTeam[3]
           +" "+ConfluenceTeam[4]+" "+ConfluenceTeam[5]+" "+ConfluenceTeam[6] + " "+ConfluenceTeam[7]
           + " "+ConfluenceTeam[8] +" "+ConfluenceTeam[9] + " "+ConfluenceTeam[10] + " "+ConfluenceTeam[11]
           + " "+ConfluenceTeam[12] +" "+ConfluenceTeam[13] +" "+ConfluenceTeam[14] +" "+ConfluenceTeam[15]
           +" "+ConfluenceTeam[16] +" "+ConfluenceTeam[17] + " "+ConfluenceTeam[18] +" "+ConfluenceTeam[19]
           +"\n " +"Confluence Results_D: "+DailyConfluenceTeam[0]+" "+DailyConfluenceTeam[1]+" "+DailyConfluenceTeam[2]+" "+DailyConfluenceTeam[3]
           +" "+DailyConfluenceTeam[4] +" "+DailyConfluenceTeam[5] +" "+DailyConfluenceTeam[6] +" "+ DailyConfluenceTeam[7]+" "
           +DailyConfluenceTeam[8]+" "+DailyConfluenceTeam[9]+" "+DailyConfluenceTeam[10]+" "+DailyConfluenceTeam[11] +" "
           +DailyConfluenceTeam[12]
          );







///                            ================================== Entry Rule #3 =========================================                   ///
// Possible Reveral
//   if(ENTRY_3_ALLOWED == true && ConfluenceTeam[5] ==1
//      && ConfluenceTeam[2] ==1 && DailyConfluenceTeam[3]==1)
//     {
//      if(Symbol() == "EURUSD"|| Symbol() == "USDJPY" ||  Symbol() == "USDCAD"  ||  Symbol() == "GBPJPY" || Symbol() == "XAUUSD")
//        {
//         if(ConfluenceTeam[16] ==1 || DailyConfluenceTeam[0] ==1 || DailyConfluenceTeam[8]==1)
//            // Possible Reveral: if no profit for now and there is a potential good entry then cancel the current order and act in reverse.
//           {
//            if(PositionGetDouble(POSITION_PROFIT) < 0 && positionType == 1)
//              {
//               CancelOrder();
//               trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),
//                                       Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
//                                       ,Ask), // Volume
//                         NULL,Ask,
//                         Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
//                         Buying_TP(suppResPrice_2[4],suppResPrice_2[5],keyLevelsMaj[2],keyLevelsMid[1]        // Take Profit
//                                   ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
//                                   ,Ask),"Entry RE-ENTRY ACTION_2");
//              }
//           }
//
//        }
//     }
// Going Up
   if(ENTRY_3_ALLOWED == true && PositionSelect(Symbol())==false && ConfluenceTeam[5] ==1
      && ConfluenceTeam[2] ==1
//      && ConfluenceTeam[7] ==1
//&& ConfluenceTeam[14]==1
//&& ConfluenceTeam[15] ==1
//&& ConfluenceTeam[0]==1 && ConfluenceTeam[14]==1 && ConfluenceTeam[13] ==1
//&& ConfluenceTeam[0] ==1 && ConfluenceTeam[11] ==1
//&& DailyConfluenceTeam[12] == 1
     )
     {
      //if(ConfluenceTeam[2]==1)
      //  {
      //   trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),
      //                           Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
      //                           ,Ask), // Volume
      //             NULL,Ask,
      //             Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
      //             Buying_TP(suppResPrice_2[4],suppResPrice_2[5],keyLevelsMaj[2],keyLevelsMid[1]        // Take Profit
      //                       ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
      //                       ,Ask),"Entry #3_1");
      //  }
      if(Symbol() != "XAUUSD")
        {

         // Re-entry Possiblity:
         //if(ConfluenceTeam[17] ==1 || DailyConfluenceTeam[0] ==1 || DailyConfluenceTeam[8]==1)
         //  {
         //   if(triggeredSLEarly == 1)
         //     {
         //      CancelOrder();
         //      trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),
         //                              Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
         //                              ,Ask), // Volume
         //                NULL,Ask,
         //                Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
         //                Buying_TP(suppResPrice_2[4],suppResPrice_2[5],keyLevelsMaj[2],keyLevelsMid[1]        // Take Profit
         //                          ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
         //                          ,Ask),"Entry RE-ENTRY ACTION");
         //     }
         //  }
         //Entry #3_3: changed both
         if(DailyConfluenceTeam[3]==1 || DailyConfluenceTeam[5] == 1)
           {
            if(ConfluenceTeam[0]==1 && ConfluenceTeam[6] ==1 && ConfluenceTeam[3] ==1 && PositionSelect(Symbol())==false
               && DailyConfluenceTeam[12] == 1
               && ConfluenceTeam[7] ==1

               //&& DailyConfluenceTeam[3]==1
               && ConfluenceTeam[15] ==1

              )
              {

               trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),
                                       Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
                                       ,Ask), // Volume
                         NULL,Ask,
                         Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
                         Buying_TP(suppResPrice_2[4],suppResPrice_2[5],keyLevelsMaj[2],keyLevelsMid[1]        // Take Profit
                                   ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
                                   ,Ask),"Entry #3_1");
              }
            // Entry3 part1 sub2
            if(ConfluenceTeam[19] ==1 && ConfluenceTeam[3] ==1
               //&& DailyConfluenceTeam[12] == 1
               && PositionSelect(Symbol())==false
               //&& DailyConfluenceTeam[3]==1
               //&& ConfluenceTeam[15] ==1

              )
              {

               trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
                                       ,Ask), // Volume
                         NULL,Ask,
                         Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
                         Buying_TP(suppResPrice_2[4],suppResPrice_2[5],keyLevelsMaj[2],keyLevelsMid[1]          // Take Profit
                                   ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
                                   ,Ask),"Entry #3_1_1");
              }



           }

         // Entry 3_2: New
         //if(DailyConfluenceTeam[3]==1)
         //  {
         //   if(ConfluenceTeam[17] ==1 || DailyConfluenceTeam[0] ==1 || DailyConfluenceTeam[8]==1)
         //     {
         //      trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
         //                              ,Ask), // Volume
         //                NULL,Ask,
         //                Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
         //                Buying_TP(suppResPrice_2[4],suppResPrice_2[5],keyLevelsMaj[2],keyLevelsMid[1]          // Take Profit
         //                          ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
         //                          ,Ask),"Entry #3_2");
         //     }
         //  }
         // Entry 3_2: New: Based on Closing too close to the trendlines with a bearish candle in this case
         if(ConfluenceTeam[0] ==1 || ConfluenceTeam[16] ==1)
            if(PositionSelect(Symbol())==false && DailyConfluenceTeam[3]==1 && Dailyrates[1].close <= Dailyrates[1].open
               && DailyConfluenceTeam[12] == 1)
              {
               if(MathAbs(Dailyrates[1].close - support_Data_D[1])*MathPow(10,_Digits)<= 500
                  || MathAbs(Dailyrates[1].low - support_Data_D[1])*MathPow(10,_Digits)<= 200
                  || MathAbs(Dailyrates[1].close - support_Data_D_2[1])*MathPow(10,_Digits)<= 500
                  || MathAbs(Dailyrates[1].low - support_Data_D_2[1])*MathPow(10,_Digits)<= 200)
                 {
                  trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
                                          ,Ask), // Volume
                            NULL,Ask,
                            Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
                            Buying_TP(suppResPrice_2[4],suppResPrice_2[5],keyLevelsMaj[2],keyLevelsMid[1]          // Take Profit
                                      ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
                                      ,Ask),"Entry #3_2_1");
                 }
               // Entry 3_2: New
               //         if(ConfluenceTeam[0] ==1 || ConfluenceTeam[16] ==1)
               //           {
               //            if(DailyConfluenceTeam[3] ==1 && PositionSelect(Symbol())==false)
               //              {
               //               trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
               //                                       ,Ask), // Volume
               //                         NULL,Ask,
               //                         Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
               //                         Buying_TP(suppResPrice_2[4],suppResPrice_2[5],keyLevelsMaj[2],keyLevelsMid[1]          // Take Profit
               //                                   ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
               //                                   ,Ask),"Entry #3_2");
               //              }
               //
               //           }
              }



        }




      if(Symbol() == "XAUUSD")
        {
         // Re-entry Possiblity:
         //if(ConfluenceTeam[17] ==1)
         //  {
         //   if(triggeredSLEarly == 1 && positionType == 1)
         //     {
         //      CancelOrder();
         //      trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),
         //                              Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
         //                              ,Ask), // Volume
         //                NULL,Ask,
         //                Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
         //                Buying_TP(suppResPrice_2[4],suppResPrice_2[5],keyLevelsMaj[2],keyLevelsMid[1]        // Take Profit
         //                          ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
         //                          ,Ask),"Entry RE-ENTRY ACTION");
         //     }
         //  }

         //         if(ConfluenceTeam[0]==1 && ConfluenceTeam[6] ==1 && ConfluenceTeam[3] ==1
         //            && DailyConfluenceTeam[4]==1
         //            && ConfluenceTeam[15] ==1
         //            && PositionSelect(Symbol())==false
         //
         //           )
         //           {
         //
         //            trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
         //                                    ,Ask), // Volume
         //                      NULL,Ask,
         //                      Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
         //                      Buying_TP(suppResPrice_2[4],suppResPrice_2[5],dcs_up[1],dcs_midd[1]          // Take Profit
         //                                ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
         //                                ,Ask),"Entry #3_1");
         //           }
         // Entry3 part1 sub2
         if(ConfluenceTeam[19] ==1 && ConfluenceTeam[3] ==1
            //&& DailyConfluenceTeam[3]==1
            && ConfluenceTeam[15] ==1 && PositionSelect(Symbol())==false

           )
           {

            trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
                                    ,Ask), // Volume
                      NULL,Ask,
                      Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
                      Buying_TP(suppResPrice_2[4],suppResPrice_2[5],dcs_up[1],dcs_midd[1]          // Take Profit
                                ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
                                ,Ask),"Entry #3_1_1");
           }
         // Entry 3_2: New: Based on Closing too close to the trendlines with a bearish candle in this case
         if(ConfluenceTeam[0] ==1 || ConfluenceTeam[16] ==1)
            if(PositionSelect(Symbol())==false && DailyConfluenceTeam[3]==1 && Dailyrates[1].close <= Dailyrates[1].open
               && DailyConfluenceTeam[12] == 1)
              {
               if(MathAbs(Dailyrates[1].close - support_Data_D[1])*MathPow(10,_Digits)<= 500
                  || MathAbs(Dailyrates[1].low - support_Data_D[1])*MathPow(10,_Digits)<= 200
                  || MathAbs(Dailyrates[1].close - support_Data_D_2[1])*MathPow(10,_Digits)<= 500
                  || MathAbs(Dailyrates[1].low - support_Data_D_2[1])*MathPow(10,_Digits)<= 200)
                 {
                  trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
                                          ,Ask), // Volume
                            NULL,Ask,
                            Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
                            Buying_TP(suppResPrice_2[4],suppResPrice_2[5],keyLevelsMaj[2],keyLevelsMid[1]          // Take Profit
                                      ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
                                      ,Ask),"Entry #3_2_1");
                 }
              }

         //if(DailyConfluenceTeam[4] == 1)
         //  {
         //   if(DailyConfluenceTeam[0] == 1 || DailyConfluenceTeam[8] ==1)
         //     {
         //      trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
         //                              ,Ask), // Volume
         //                NULL,Ask,
         //                Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
         //                Buying_TP(suppResPrice_2[4],suppResPrice_2[5],keyLevelsMaj[2],keyLevelsMid[1]          // Take Profit
         //                          ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
         //                          ,Ask),"Entry #3_2_1");
         //     }
         //  }
         // Entry 3_2: New
         //if(DailyConfluenceTeam[3]==1 && PositionSelect(Symbol())==false)
         //  {
         //   if(ConfluenceTeam[17] ==1 || DailyConfluenceTeam[0] ==1 || DailyConfluenceTeam[8]==1)
         //     {
         //      trade.Buy(Buying_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]) // Volume
         //                              ,Ask), // Volume
         //                NULL,Ask,
         //                Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0]),                  // Stop Loss
         //                Buying_TP(suppResPrice_2[4],suppResPrice_2[5],keyLevelsMaj[2],keyLevelsMid[1]          // Take Profit
         //                          ,Buying_SL(suppResPrice[3],suppResPrice[2],suppResPrice[1],suppResPrice[0])
         //                          ,Ask),"Entry #3_2");
         //     }
         //  }

        }


      //Entry #3_2




      sellCheck = true;
      buyCheck = false;


     }

// Possible Reveral
//   if(ENTRY_3_ALLOWED == true && ConfluenceTeam[5] ==0
//      && ConfluenceTeam[2] ==0
//      && ConfluenceTeam[7] ==0 && DailyConfluenceTeam[3]==0)
//     {
//      if(Symbol() == "EURUSD" || Symbol() == "USDJPY" ||  Symbol() == "USDCAD"  ||  Symbol() == "GBPJPY" || Symbol() == "XAUUSD")
//        {
//         if(ConfluenceTeam[17] ==0 || DailyConfluenceTeam[1] ==0 || DailyConfluenceTeam[9]==0)
//           {
//            // Possible Reveral: if no profit for now and there is a potential good entry then cancel the current order and act in reverse.
//            if(PositionGetDouble(POSITION_PROFIT) < 0 && positionType == 0)
//              {
//               CancelOrder();
//               trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
//                                         Bid), NULL,Bid,
//                          Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
//                          Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
//                                     Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
//                                     ,Bid),"Entry RE-ENTRY ACTION_2");
//              }
//           }
//
//        }
//     }

// Going Down: Entry #3
   if(ENTRY_3_ALLOWED == true && PositionSelect(Symbol())==false && ConfluenceTeam[5] ==0
      && ConfluenceTeam[2] ==0
//&& DailyConfluenceTeam[12] == 0
//&& ConfluenceTeam[7] ==0
//&& ConfluenceTeam[14]==1
//&& ConfluenceTeam[15] ==0
//&& ConfluenceTeam[1] ==0 && ConfluenceTeam[14]==1 && ConfluenceTeam[13] ==1
//&& ConfluenceTeam[1] ==0 && ConfluenceTeam[11] ==1

     )
     {
      //if(ConfluenceTeam[2]==0)
      //  {
      //   trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
      //                             Bid), NULL,Bid,
      //              Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
      //              Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
      //                         Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
      //                         ,Bid),"Entry #3_1");
      //  }
      if(Symbol() != "XAUUSD")
        {

         // Re-entry Possiblity:
         //if(ConfluenceTeam[17] ==0 || DailyConfluenceTeam[1] ==0 || DailyConfluenceTeam[9]==0)
         //  {
         //   if(triggeredSLEarly == 1)
         //     {
         //      CancelOrder();
         //      trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
         //                                Bid), NULL,Bid,
         //                 Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
         //                 Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
         //                            Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
         //                            ,Bid),"Entry RE-ENTRY ACTION");
         //     }
         //  }

         // Entry 3_3
         if(DailyConfluenceTeam[3]==0 || DailyConfluenceTeam[5] == 0)
           {
            if(ConfluenceTeam[1]==0 && ConfluenceTeam[6] ==0 && ConfluenceTeam[3] ==0 && ConfluenceTeam[7] ==0

               && DailyConfluenceTeam[12] == 0
               && PositionSelect(Symbol())==false
               && ConfluenceTeam[15] ==0
               //&& DailyConfluenceTeam[3]==1

              )
              {

               trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
                                         Bid), NULL,Bid,
                          Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
                          Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
                                     Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
                                     ,Bid),"Entry #3_1");
              }
            // Entry3 part1 sub2
            if(ConfluenceTeam[19] == 0 && ConfluenceTeam[3] ==0
               //&& DailyConfluenceTeam[12] == 0
               && PositionSelect(Symbol())==false
               //&& ConfluenceTeam[15] ==0

              )
              {

               trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
                                         Bid), NULL,Bid,
                          Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
                          Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
                                     Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
                                     ,Bid),"Entry #3_1_1");
              }
           }
         // Entry 3_2: New: Based on Closing too close to the trendlines with a bullish candle in this case
         if(PositionSelect(Symbol())==false && DailyConfluenceTeam[3]== 0 && Dailyrates[1].close >= Dailyrates[1].open
            && DailyConfluenceTeam[12] == 0)
           {
            if(MathAbs(Dailyrates[1].close - resistance_Data_D[1])*MathPow(10,_Digits)<= 500
               || MathAbs(Dailyrates[1].high - resistance_Data_D[1])*MathPow(10,_Digits)<= 200
               || MathAbs(Dailyrates[1].close - resistance_Data_D_2[1])*MathPow(10,_Digits)<= 500
               || MathAbs(Dailyrates[1].high - resistance_Data_D_2[1])*MathPow(10,_Digits)<= 200)
              {
               trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
                                         Bid), NULL,Bid,
                          Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
                          Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
                                     Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
                                     ,Bid),"Entry #3_2_1");
              }

            //if(ConfluenceTeam[1] ==0 || ConfluenceTeam[17] ==0)
            //  {
            //   if(DailyConfluenceTeam[3] ==0 && PositionSelect(Symbol())==false)
            //     {
            //      trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
            //                                Bid), NULL,Bid,
            //                 Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
            //                 Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
            //                            Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
            //                            ,Bid),"Entry #3_2");
            //     }
            //  }
           }
        }
      // Entry 3_2: New
      //if(DailyConfluenceTeam[3] == 0 && PositionSelect(Symbol())==false)
      //  {
      //   if(ConfluenceTeam[17] ==0 || DailyConfluenceTeam[1] ==0 || DailyConfluenceTeam[9]==0)
      //     {
      //      trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
      //                                Bid), NULL,Bid,
      //                 Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
      //                 Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
      //                            Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
      //                            ,Bid),"Entry #3_2");
      //     }
      //  }











      if(Symbol() == "XAUUSD")
        {
         // Re-entry Possiblity:
         //if(ConfluenceTeam[17] ==0)
         //  {
         //   if(triggeredSLEarly == 1 && positionType == 0)
         //     {
         //      CancelOrder();
         //      trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
         //                                Bid), NULL,Bid,
         //                 Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
         //                 Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
         //                            Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
         //                            ,Bid),"Entry RE-ENTRY ACTION");
         //     }
         //  }
         //         if(ConfluenceTeam[1]==0 && ConfluenceTeam[6] ==0 && ConfluenceTeam[3] ==0 && ConfluenceTeam[15] ==0
         //            && PositionSelect(Symbol())==false
         //            && DailyConfluenceTeam[4]==0
         //
         //           )
         //           {
         //
         //            trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
         //                                      Bid), NULL,Bid,
         //                       Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
         //                       Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
         //                                  Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
         //                                  ,Bid),"Entry #3_1");
         //           }
         // Entry3 part1 sub2
         if(ConfluenceTeam[19] == 0 && ConfluenceTeam[3] ==0
            && ConfluenceTeam[15] ==0 && PositionSelect(Symbol())==false

           )
           {

            trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
                                      Bid), NULL,Bid,
                       Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
                       Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
                                  Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
                                  ,Bid),"Entry #3_1_1");
           }
         // Entry 3_2: New: Based on Closing too close to the trendlines with a bullish candle in this case
         if(PositionSelect(Symbol())==false && DailyConfluenceTeam[3]== 0 && Dailyrates[1].close >= Dailyrates[1].open
            && DailyConfluenceTeam[12] == 0)
           {
            if(MathAbs(Dailyrates[1].close - resistance_Data_D[1])*MathPow(10,_Digits)<= 500
               || MathAbs(Dailyrates[1].high - resistance_Data_D[1])*MathPow(10,_Digits)<= 200
               || MathAbs(Dailyrates[1].close - resistance_Data_D_2[1])*MathPow(10,_Digits)<= 500
               || MathAbs(Dailyrates[1].high - resistance_Data_D_2[1])*MathPow(10,_Digits)<= 200)
              {
               trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
                                         Bid), NULL,Bid,
                          Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
                          Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
                                     Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
                                     ,Bid),"Entry #3_2_1");
              }
           }

         // Entry 3_2: New
         //if(
         //   Dailyrates[1].high >= resistance_Data_D[1] || Dailyrates[1].high >= resistance_Data_D_2[1]
         //   ||
         //   Dailyrates[1].high >= resistance_Data_D_2[2] || Dailyrates[2].high >= resistance_Data_D_2[2])
         //  {
         //   trade.Sell(Selling_Volume(0.0045*AccountInfoDouble(ACCOUNT_BALANCE),Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]), // Volume to trade with
         //                             Bid), NULL,Bid,
         //              Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7]),           // Stop Loss
         //              Selling_TP(suppResPrice_2[3],suppResPrice_2[2],dcs_midd[1],dcs_low[1], // Take Profit
         //                         Selling_SL(suppResPrice[4],suppResPrice[5],suppResPrice[6],suppResPrice[7])
         //                         ,Bid),"Entry #3_2");
         //  }
        }








      sellCheck = false;
      buyCheck = true;


     }
//Print("Volume bro: "+ Selling_Volume(800,28.748,27.824));
//Print("Decimal ceiled: "+MathCeil(1.4));
   if(PositionSelect(Symbol())==true)
     {
      positionType = PositionGetInteger(POSITION_TYPE);
     }
   Print("PositionGetInteger(POSITION_TYPE): "+PositionGetInteger(POSITION_TYPE) +" PositionType: "+positionType);
//Print("Profit: "+PositionGetDouble(POSITION_PROFIT) + " sl and TP: "+PositionGetDouble(POSITION_SL) +" "+PositionGetDouble(POSITION_TP));
// Change Stop loss: Protection System
   if(PositionSelect(Symbol())==true && PositionGetInteger(POSITION_TYPE) == 1)
     {
      // Selling: Entry_2 and Entry 3_1_1
      if(PositionGetString(POSITION_COMMENT) =="Entry #3_2" || PositionGetString(POSITION_COMMENT) =="Entry #3_1_1"
         || PositionGetString(POSITION_COMMENT) =="Entry #3_3" || PositionGetString(POSITION_COMMENT) =="Entry #3_1"
         || PositionGetString(POSITION_COMMENT) == "Entry #3_2_1" || PositionGetString(POSITION_COMMENT) =="Entry RE-ENTRY ACTION"
         || PositionGetString(POSITION_COMMENT) == "Entry RE-ENTRY ACTION_2")
        {
         // Only change the SL when at least the risked amount can be recovered
         if(ConfluenceTeam[7] == 1)
           {
            if(PositionGetDouble(POSITION_PROFIT) > ((PositionGetDouble(POSITION_SL) - PositionGetDouble(POSITION_PRICE_OPEN))*MathPow(10,_Digits))
              )
              {
               changeSLEntry_3_Sell(ConfluenceTeam[7],(goldenMovingAverageArray[1] + 100*_Point),
                                    ConfluenceTeam[1],ConfluenceTeam[6],ConfluenceTeam[3]);
              }
           }
         // Verion 2 with normal MA s
         //if(ConfluenceTeam[3] == 1)
         //  {
         //   if(PositionGetDouble(POSITION_PROFIT) >= 2*((PositionGetDouble(POSITION_SL) - PositionGetDouble(POSITION_PRICE_OPEN))*MathPow(10,_Digits))
         //     )
         //     {
         //      changeSLEntry_3_Sell(ConfluenceTeam[7],(myMovingAverageArray_lowPer[1] + 40*_Point),
         //                           ConfluenceTeam[1],ConfluenceTeam[6],ConfluenceTeam[3]);
         //     }
         //  }
         //else
         //   if(PositionGetDouble(POSITION_PROFIT) >= 1.80*((PositionGetDouble(POSITION_SL) - PositionGetDouble(POSITION_PRICE_OPEN))*MathPow(10,_Digits))
         //     )
         //     {
         //      changeSLEntry_3_Sell(ConfluenceTeam[7],(myMovingAverageArray_lowPer[1] - 40*_Point),
         //                           ConfluenceTeam[1],ConfluenceTeam[6],ConfluenceTeam[3]);
         //     }

        }


     }

   Print("pOSITION Profit: "+PositionGetDouble(POSITION_PROFIT));
   Print("Position SL in pips: "+((PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_SL))*MathPow(10,_Digits)));
   if(PositionSelect(Symbol())==true && PositionGetInteger(POSITION_TYPE) == 0)
     {
      // Buying: Entry 3_2 and Entry 3_1_1
      if(PositionGetString(POSITION_COMMENT) =="Entry #3_2" || PositionGetString(POSITION_COMMENT) =="Entry #3_1_1"
         || PositionGetString(POSITION_COMMENT) =="Entry #3_3" || PositionGetString(POSITION_COMMENT) =="Entry #3_1"
         || PositionGetString(POSITION_COMMENT) == "Entry #3_2_1" || PositionGetString(POSITION_COMMENT) =="Entry RE-ENTRY ACTION"
         || PositionGetString(POSITION_COMMENT) == "Entry RE-ENTRY ACTION_2")
        {
         if(ConfluenceTeam[7] == 0)
           {
            // Only change the SL when at least the risked amount can be recovered
            if(PositionGetDouble(POSITION_PROFIT) > ((PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_SL))*MathPow(10,_Digits))
              )
              {
               changeSLEntry_3_Buy(ConfluenceTeam[7],(goldenMovingAverageArray[1] - 90*_Point),
                                   ConfluenceTeam[0],ConfluenceTeam[6],ConfluenceTeam[3]);
              }
           }
         // Verion 2 with normal MA s
         //if(ConfluenceTeam[3] == 0)
         //  {
         //   if(PositionGetDouble(POSITION_PROFIT) >= 2*((PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_SL))*MathPow(10,_Digits))
         //     )
         //     {
         //      changeSLEntry_3_Buy(ConfluenceTeam[7],(myMovingAverageArray_lowPer[1] - 50*_Point),
         //                          ConfluenceTeam[0],ConfluenceTeam[6],ConfluenceTeam[3]);
         //     }
         //  }
         //else
         //   if(PositionGetDouble(POSITION_PROFIT) >= 1.79*((PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_SL))*MathPow(10,_Digits))
         //     )
         //     {
         //      changeSLEntry_3_Buy(ConfluenceTeam[7],(myMovingAverageArray_lowPer[1] + 50*_Point),
         //                          ConfluenceTeam[0],ConfluenceTeam[6],ConfluenceTeam[3]);
         //     }

        }



     }
// Testing Entry_4:
//if(ConfluenceTeam[1] ==0 &&ConfluenceTeam[7] ==0  && PositionSelect(Symbol())==false)
//  {
//   trade.Sell(Selling_Volume(400,(goldenMovingAverageArray[1] + 200*_Point), // Volume to trade with
//                             Bid),NULL,Bid,(Bid + 50 *_Point),(Bid - 250 *_Point),NULL);
//  }
//if(ConfluenceTeam[0] ==1 && ConfluenceTeam[7] ==1 && PositionSelect(Symbol())== false)
//  {
//   trade.Buy(Buying_Volume(400,(goldenMovingAverageArray[1] - 200*_Point), // Volume to trade with
//                           Ask),NULL,Ask,(Ask - 80 * _Point),(Ask + 800 * _Point),NULL);
//  }

// Activate CHANGE SL 30 pips if there is a sign of exhaustion
//if(PositionSelect(Symbol())==true && ExhaustionPatternStart == true && PositionGetInteger(POSITION_TYPE) == 1)
//  {
//   changeSLSelling(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//  }
//if(PositionSelect(Symbol())==true && ExhaustionPatternStart == true && PositionGetInteger(POSITION_TYPE) == 0)
//  {
//   changeSLBuying(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//  }



///         ========================= ^^ Entry Rule #3 ^^ ==================================   ///


//     ****************************************      Entry Rules         *********************************************** //
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   Print("price cuurent "+PositionGetDouble(POSITION_PRICE_OPEN) +" digits: "+_Digits);
   Print("triggeredSLEarly: "+triggeredSLEarly);
//Print("profit cuurent "+PositionGetDouble(POSITION_PROFIT));
//Print("dcsUP[1]: "+dcs_up[1] + " dcslow[1]: "+dcs_low[1]);
//Print("CHANGEDSL: "+changedSL + " TRIGGEREDSLearly: "+triggeredSLEarly + " "+ PositionGetString(POSITION_COMMENT));
//Print("Crossed MA price: "+price_MA_Crossed);


//Print("Here is the results: "+resistance_Data[0]+" [1]: "+resistance_Data[1]);
//Print("The rest of results: "+support_Data[0] + " [1]: "+support_Data[1]);
   Print("Here is the results: "+trendSignalBelow);
   Print("The rest of results: "+trendSignalAbove);

//Print("MA: "+myMovingAverageArray_lowPer[0] + " [1]: "+myMovingAverageArray_lowPer[1]);
//P'
   CancelFridayOrders();

  }

int counterBuyPos, counterSellPos;
double newStopLoss;
double counterBool =  false;
//+------------------------------------------------------------------+
void changeSLSelling(double ratesClose, double entryPrice)
  {

   newStopLoss = entryPrice;
   if((entryPrice) > 0)
     {
      if(MathAbs(ratesClose - entryPrice) >= 50*_Point)
        {
         //newStopLoss -= (30*_Point);
         ////Print("Changing right now change SL Selling "+(50*_Point)+" "
         //+(ratesClose - entryPrice)+" entry price from change: "+entryPrice);
         //if entry price is Bid
         TraillingStopLoss(entryPrice,(entryPrice - 30*_Point));
         // This is for a re-entry opportunity
         changedSL = true;
         //goldenMACounter = 0;
         //goldenMACounter_2 = 0;
        }
      else
        {
         changedSL = false;
         triggeredSLEarly =  -1;
         //Print("Not Working yet change SL Selling");
        }
     }
   else
     {
      changedSL = false;
      triggeredSLEarly =  -1;
      //Print("Nope from change SL Buying");
     }

//else
//   if(sellCheck == true && counterBool == true)
//     {
//      TraillingStopLoss(entryPrice,priceSL);
//      //Print("dON'T KNOW WHAT TO DO");
//     }

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void changeSLBuying(double ratesClose, double entryPrice)
  {

   newStopLoss = entryPrice;
   if((entryPrice) >0)
     {
      if((ratesClose - entryPrice) >= 50*_Point)
        {
         //newStopLoss -= (30*_Point);
         //Print("Changing right now change SL Buying "+(50*_Point) +" "+((ratesClose - entryPrice)));
         //if entry price is Ask
         TraillingStopLoss(entryPrice,(entryPrice + 30*_Point));
         // This is for a re-entry opportunity
         changedSL = true;
         //goldenMACounter = 0;
         //goldenMACounter_2 = 0;
        }
      else
        {
         changedSL = false;
         triggeredSLEarly =  -1;
         //Print("Not Working yet change SL Buying");
        }
     }
   else
     {
      changedSL = false;
      triggeredSLEarly = -1;
      //Print("Nope from change SL Buying");
     }


  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void changeSLEntry_3_Buy(int confluence_7, double newSL, int confluence_0, int confluence_6, int confluence_3)
  {
   if(PositionSelect(Symbol())==true && PositionGetInteger(POSITION_TYPE) == 0)
     {
      if(confluence_7 ==0 || confluence_3 == 0)
        {
         //Print("cHANGE SL ");
         TraillingStopLoss(0,newSL);

         changedSL = true;
         //goldenMACounter = 0;
         //goldenMACounter_2 = 0;
        }
      else
        {
         changedSL = false;
         triggeredSLEarly =  -1;
         //Print("Not Working yet change SL Buying");
        }
      // checks if trendLine is in line with the position taken
      //if(confluence_0 == 0 || confluence_6 ==0)
      //  {
      //   if(newSL < PositionGetDouble(POSITION_PRICE_OPEN))
      //     {
      //      //changeSLBuying(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
      //     }
      //  }




     }

  }
//+------------------------------------------------------------------+
void changeSLEntry_3_Sell(int confluence_7, double newSL, int confluence_1, int confluence_6, int confluence_3)
  {

   if(PositionSelect(Symbol())==true && PositionGetInteger(POSITION_TYPE) == 1)
     {
      if(confluence_7 ==1 || confluence_3 ==1)
        {
         //Print("cHANGE SL ");
         TraillingStopLoss(0,newSL);
         changedSL = true;
         //goldenMACounter = 0;
         //goldenMACounter_2 = 0;
        }
      else
        {
         changedSL = false;
         triggeredSLEarly =  -1;
         //Print("Not Working yet change SL Selling");
        }
      // checks if trendLine is in line with the position taken
      if(confluence_1 == 1 || confluence_6 == 1)
        {
         if(newSL > PositionGetDouble(POSITION_PRICE_OPEN))
           {
            //changeSLSelling(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
           }
        }






     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CancelFridayOrders()
  {

   MqlDateTime STime;
   datetime time_current=TimeCurrent();
   datetime time_local=TimeLocal();

   TimeToStruct(time_current,STime);
//Print("Time Current ",TimeToString(time_current,TIME_DATE|TIME_SECONDS)," day of week ",DayOfWeekDescription(STime.day_of_week));
   Print("Today is: "+STime.day_of_week);

// If there is an open Position, profit is positive and the day of the week is friday, then cancel any order
   if(PositionSelect(Symbol())==true && STime.day_of_week == 5 && STime.hour >= 19)
     {
      CancelOrder();
      triggeredSLEarly = 1;
     }

  }


//+------------------------------------------------------------------+
//|  Close Current Order                                             |
//+------------------------------------------------------------------+
void CancelOrder()
  {
//trade.OrderDelete(ticketOrder);
   for(i=PositionsTotal(); i>=0; i--)
     {
      if(Symbol()==PositionGetSymbol(i))
        {
         // get ticket number
         ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
         //// get current stop loss
         //double currentStopLoss = PositionGetDouble(POSITION_SL);

         // Modify Stpo loss
         trade.PositionClose(PositionTicket);
        }
     }

  }
//+------------------------------------------------------------------+
int triggeredSLEarly = -1;
bool changedSL = false;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
   if(HistoryDealSelect(trans.deal) == true)
     {
      ENUM_DEAL_ENTRY deal_entry=(ENUM_DEAL_ENTRY) HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
      ENUM_DEAL_REASON deal_reason=(ENUM_DEAL_REASON) HistoryDealGetInteger(trans.deal,DEAL_REASON);
      PrintFormat("deal entry type=%s trans type=%s trans deal type=%s order-ticket=%d deal-ticket=%d deal-reason=%s"
                  ,EnumToString(deal_entry),EnumToString(trans.type)
                  ,EnumToString(trans.deal_type),trans.order,trans.deal
                  ,EnumToString(deal_reason));
      if(EnumToString(deal_reason) == "DEAL_REASON_SL")
        {
         triggeredSLEarly = 1;
         Print("ticket ",trans.order, "  triggered SL");
        }
      else
        {
         triggeredSLEarly = -1;
        }

      //      if(AccountInfoDouble(ACCOUNT_EQUITY) > AccountInfoDouble(ACCOUNT_BALANCE))
      //        {
      //         CancelOrder(trans.deal);
      //
      //        }

     }

  }
//+------------------------------------------------------------------+
bool ConsolidationPatternStart = false;
bool ExhaustionPatternStart = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EntryConsolidationPattern()
  {
// Start of the pattern
   if(BufferColors[3] == 2.0 && BufferColors[4] ==2.0 || ConsolidationPatternStart == true)
     {
      if(BufferColors[2] ==1.0 || BufferColors[2] ==0.0 || ConsolidationPatternStart == true)
        {
         if(BufferColors[1] == 1.0 || BufferColors[1] == 0.0)
           {
            //Print("Start of Pattern Finished !!!");
            ConsolidationPatternStart = true;
           }
         else
            if(BufferColors[1] ==2.0)
              {
               //Print(" No more Pattern  !!!");
               ConsolidationPatternStart = false;
              }
        }
      //else // // A pattern to avoid: when the market is suddenly aggressive(pushing phase), then it's not a good
      // idea.
      //   if(BufferColors[2] ==0.0)
      //     {
      //      ConsolidationPatternStart = false;
      //     }
     }
   if(BufferColors[3] == 2.0 || ConsolidationPatternStart == true)
     {
      if(BufferColors[2] ==1.0 || BufferColors[2] ==0.0 || ConsolidationPatternStart == true)
        {
         if(BufferColors[1] == 1.0 || BufferColors[1] == 0.0)
           {
            //Print("Start of Pattern Finished !!!");
            ConsolidationPatternStart = true;
           }
         else
            if(BufferColors[1] ==2.0)
              {
               //Print(" No more Pattern  !!!");
               ConsolidationPatternStart = false;
              }
        }
     }
//  // the recent candle needs to have a greater trend_range bar than its previous neighoubour
//if(BufferMax[1] >= 1.90*BufferMax[3] || BufferFlat[1] >= 1.90*BufferFlat[3])
//  {
//   ConsolidationPatternStart = true;
//  }
//else
//  {
//   ConsolidationPatternStart = false;
//  }

  }
//+------------------------------------------------------------------+
void ExhaustionPattern()
  {
   if(BufferColors[1] == 0.0 || BufferColors[1] == 1.0)
     {
      if(BufferColors[2]== 2.0)
        {
         if(BufferColors[3] == 0.0 || BufferColors[3]== 1.0)
           {
            //Print("Exhaustion Pattern Completed");
            ExhaustionPatternStart = true;
           }
         else
           {
            //Print("Not an E. pattern");
            ExhaustionPatternStart = false;
           }
        }
      if(BufferColors[3] == 2.0)
        {
         if(BufferColors[4] == 0.0 || BufferColors[4]== 1.0)
           {
            //Print("Exhaustion Pattern Completed");
            ExhaustionPatternStart = true;
           }
         else
           {
            //Print("Not an E. pattern");
            ExhaustionPatternStart = false;
           }
        }
      if(BufferColors[4] == 2.0)
        {
         if(BufferColors[5] == 0.0 || BufferColors[5]== 1.0)
           {
            //Print("Exhaustion Pattern Completed");
            ExhaustionPatternStart = true;
           }
         else
           {
            //Print("Not an E. pattern");
            ExhaustionPatternStart = false;
           }
        }
     }
  }
//+------------------------------------------------------------------+
// Our three Major Key Levels Zones
int Upper_DoncInd_MajKL= 0;
int Lower_DoncInd_MajKL= 0;
int Half_DoncInd_MajKL_Up= 0;
int Half_DoncInd_MajKL_Down= 0;
int Daily_MajKL_Up= 0;
int Daily_MajKL_Down= 0;
int Psych_MajKL_Up = 0;
int Psych_MajKL_Down = 0;
int Psych_MajKL_Midd_Up = 0;
int Psych_MajKL_Midd_Down = 0;
//+------------------------------------------------------------------+
//|   Defining Major Key Levels: Relay System where
//    we can know the direction of Price                             |
//+------------------------------------------------------------------+
void MajorKeyLevelsZone(double &suppResPrice_2[])

  {
// First Zone: with first half of Donc Ind
   if((dcs_up[1] - 0.15*MathAbs(dcs_up[1] - dcs_midd[1])) <= rates[1].high)
     {
      Upper_DoncInd_MajKL = 1;
      Half_DoncInd_MajKL_Down= 0;
      Half_DoncInd_MajKL_Up= 0;
     }
// Second Zone: with second half of Donc Ind
   if((dcs_low[1] + 0.15*MathAbs(dcs_low[1] - dcs_midd[1])) >= rates[1].low
     )
     {
      Lower_DoncInd_MajKL = 1;
      Half_DoncInd_MajKL_Up= 0;
      Half_DoncInd_MajKL_Down = 0;
     }

// Third Zone: with the half of Donc Ind
   if((dcs_midd[1] + 0.15*MathAbs(dcs_up[1] - dcs_midd[1])) >= rates[1].low && (dcs_midd[1]) <= rates[1].low)
     {
      // facing up.
      Half_DoncInd_MajKL_Down = 1;
      Upper_DoncInd_MajKL = 0;
      Lower_DoncInd_MajKL = 0;
      Half_DoncInd_MajKL_Up =0;
     }

   if((dcs_midd[1] - 0.15*MathAbs(dcs_low[1] - dcs_midd[1])) <= rates[1].high && (dcs_midd[1]) >= rates[1].high)
     {
      // facing down.
      Half_DoncInd_MajKL_Up = 1;
      Lower_DoncInd_MajKL = 0;
      Upper_DoncInd_MajKL = 0;
      Half_DoncInd_MajKL_Down = 0;
     }

// Fourth Zone: Daily SuppRes_2 of MQLTA Lines
   if((suppResPrice_2[4] - 0.15*MathAbs(suppResPrice_2[4] - suppResPrice_2[3])) <= rates[1].high
     )
     {

      Daily_MajKL_Up = 1;
      Daily_MajKL_Down = 0;
     }
   if((suppResPrice_2[3] + 0.15*MathAbs(suppResPrice_2[4] - suppResPrice_2[3])) >= rates[1].low)
     {
      Daily_MajKL_Down = 1;
      Daily_MajKL_Up = 0;
     }
// Fifth Zone: Psychological Levels
   if(keyLevelsMaj[2] - 0.15*MathAbs(keyLevelsMaj[1] - keyLevelsMaj[2]) <= rates[1].high)
     {
      Print("The 15% is: "+0.15*MathAbs(keyLevelsMaj[1] - keyLevelsMaj[2]));
      Psych_MajKL_Up = 1;
      Psych_MajKL_Down = 0;
     }
   if(keyLevelsMaj[1] + 0.15*MathAbs(keyLevelsMaj[1] - keyLevelsMaj[2]) >= rates[1].low)
     {
      Print("The 15% of down is: "+0.15*MathAbs(keyLevelsMaj[1] - keyLevelsMaj[2]));
      Psych_MajKL_Down = 1;
      Psych_MajKL_Up = 0;
     }
// Sixth Zone: Middle Psychological Levels
   if((keyLevelsMid[1] + 0.15*MathAbs(keyLevelsMaj[2] - keyLevelsMid[1])) >= rates[1].low && (keyLevelsMid[1]) <= rates[1].low)
     {
      Psych_MajKL_Midd_Up = 1;
      Psych_MajKL_Midd_Down = 0;
     }
   if((keyLevelsMid[1] - 0.15*MathAbs(keyLevelsMaj[1] - keyLevelsMid[1])) <= rates[1].low && (keyLevelsMid[1]) >= rates[1].high)
     {
      Psych_MajKL_Midd_Up = 0;
      Psych_MajKL_Midd_Down = 1;
     }
//else
//  {
//   Daily_MajKL_Up = 0;
//  }
//Comment(
//   "\n     Daily MajKL_Up: "+Daily_MajKL_Up
//   +"\n     Daily MajKL_Down: "+Daily_MajKL_Down
//   +"\n     Middle PsychMaj dOWN: "+Psych_MajKL_Midd_Down
//   +"\n     Middle PsychMaj Up: "+Psych_MajKL_Midd_Up);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Buying_SL(double first_SL,double second_SL, double third_SL, double fourth_SL)
  {
   if(first_SL < goldenMovingAverageArray[1] && first_SL < (price_MA_Crossed -20*_Point))
     {
      return (first_SL - 50*_Point);
     }
   else
      if(second_SL < goldenMovingAverageArray[1] && second_SL < (price_MA_Crossed -20*_Point))
        {
         return (second_SL - 50*_Point);
        }
      else
         if(third_SL < goldenMovingAverageArray[1] && third_SL < (price_MA_Crossed -20*_Point))
           {
            return (third_SL - 50*_Point);
           }
         else
           {
            return (fourth_SL - 50*_Point);
           }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Selling_SL(double first_SL,double second_SL, double third_SL, double fourth_SL)
  {
   if(first_SL > goldenMovingAverageArray[1] && first_SL > (price_MA_Crossed +20*_Point))
     {
      return (first_SL + 50*_Point);
     }
   else
      if(second_SL > goldenMovingAverageArray[1] && second_SL > (price_MA_Crossed +30*_Point))
        {
         return (second_SL + 50*_Point);
        }
      else
         if(third_SL > goldenMovingAverageArray[1] && third_SL > (price_MA_Crossed +30*_Point))
           {
            return (third_SL + 50*_Point);
           }
         else
           {
            return (fourth_SL + 50*_Point);
           }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Buying_TP(double first_TP,double second_TP, double third_TP, double fourth_TP,double curr_SL,double Ask)
  {
// First of all, the TP needs to respect the "at least 1 to 3 Risk-Reward ratio"
   if((3*MathAbs(Ask - curr_SL) + Ask) < first_TP && first_TP !=0)
     {
      Print("1st TP");
      return first_TP;
     }
   else
      if((3*MathAbs(Ask - curr_SL) + Ask) < second_TP && second_TP !=0)
        {
         Print("2ND TP");
         return second_TP;
        }
      else
         if((3*MathAbs(Ask - curr_SL) + Ask) < third_TP && third_TP !=0)
           {
            Print("3rd TP");
            return third_TP;
           }
         else
            if((3*MathAbs(Ask - curr_SL) + Ask) < fourth_TP && fourth_TP !=0)
              {
               Print("4TH TP");
               return fourth_TP;
              }

            else
              {
               Print("Its because of me Last ONe !!!!!!!!");
               return (2*MathAbs(Ask - curr_SL) + Ask);
              }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Selling_TP(double first_TP,double second_TP, double third_TP,double fourth_TP, double curr_SL,double Bid)
  {
// First of all, the TP needs to respect the at least 1 to 3 Risk-Reward ratio
   if((Bid - 3*MathAbs(Bid - curr_SL)) > first_TP && first_TP !=0)
     {
      Print("1st TP");
      return first_TP;
     }
   else
      if((Bid - 3*MathAbs(Bid - curr_SL)) > second_TP && second_TP !=0)
        {
         Print("2ND TP");
         return second_TP;
        }
      else
         if((Bid - 3*MathAbs(Bid - curr_SL)) > third_TP && third_TP !=0)
           {
            Print("3rd TP");
            return third_TP;
           }
         else
            if((Bid - 3*MathAbs(Bid - curr_SL)) > fourth_TP && fourth_TP !=0)
              {
               Print("4TH TP");
               return fourth_TP;
              }
            else
              {
               Print("Its because of me Last One !!!!!!!!");
               return (Bid - 2*MathAbs(Bid - curr_SL));
              }

  }
//+------------------------------------------------------------------+
const double XAG_USD_MagicNumber =5;
const double GBP_AUD_MagicNumber =0.673980;
const double XAU_USD_MagicNumber = 1;
const double EUR_USD_MagicNumber = 1;
const double USD_JPY_MagicNumber = 0.910341;
const double GBP_JPY_MagicNumber =0.910341;
const double USD_CAD_MagicNumber = 0.752819;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
const double Buying_Volume(const double amt_to_risk, const double curr_SL, const double curr_Ask)
  {
   double magicNumberChosen;
   if(Symbol() == "EURUSD")
     {
      magicNumberChosen = EUR_USD_MagicNumber;
      //Print("iT IS SIR");
     }
   else
      if(Symbol() == "XAUUSD")
        {
         magicNumberChosen = XAU_USD_MagicNumber;
         //Print("iT IS SIR GOLD");
        }
      else
         if(Symbol() == "XAGUSD")
           {
            magicNumberChosen = XAG_USD_MagicNumber;
           }
         else
            if(Symbol() == "GBPAUD")
              {
               magicNumberChosen = GBP_AUD_MagicNumber;
              }
            else
               if(Symbol() == "USDJPY")
                 {
                  magicNumberChosen = USD_JPY_MagicNumber;
                  //Print("iT IS SIR GOLD");
                 }
               else
                  if(Symbol() == "GBPJPY")
                    {
                     magicNumberChosen = GBP_JPY_MagicNumber;
                    }
                  else
                     if(Symbol() == "USDCAD")
                       {
                        magicNumberChosen = USD_CAD_MagicNumber;
                       }
                     //else
                     //   if(Symbol() == "US30.cash")
                     //     {
                     //      magicNumberChosen = 13.7665;
                     //     }
                     else
                       {
                        magicNumberChosen = 1;
                       }
//Print("currSL: "+curr_SL);
//Print("current SL: "+PositionGetDouble(POSITION_SL));
   const double pips = (MathAbs(curr_Ask - curr_SL)*MathPow(10,_Digits));
   const double result = NormalizeDouble((amt_to_risk/(magicNumberChosen*pips)),2);


//Print("tHE PIPS: "+pips);

//Print("Normalized: "+ NormalizeDouble((amt_to_risk/(XAU_USD_MagicNumber*pips)),2));
   return result;
  }
double Volume_Test;
double Vol_Testing = 0.2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
const double Selling_Volume(const double amt_to_risk, const double curr_SL, const double curr_Bid)
  {
   double magicNumberChosen;
   if(Symbol() == "EURUSD")
     {
      magicNumberChosen = EUR_USD_MagicNumber;
      //Print("iT IS SIR");
     }
   else
      if(Symbol() == "XAUUSD")
        {
         magicNumberChosen = XAU_USD_MagicNumber;
         //Print("iT IS SIR GOLD");
        }
      else
         if(Symbol() == "XAGUSD")
           {
            magicNumberChosen = XAG_USD_MagicNumber;
           }
         else
            if(Symbol() == "GBPAUD")
              {
               magicNumberChosen = GBP_AUD_MagicNumber;
              }
            else
               if(Symbol() == "USDJPY")
                 {
                  magicNumberChosen = USD_JPY_MagicNumber;
                  //Print("iT IS SIR GOLD");
                 }
               else
                  if(Symbol() == "GBPJPY")
                    {
                     magicNumberChosen = GBP_JPY_MagicNumber;
                    }
                  else
                     if(Symbol() == "USDCAD")
                       {
                        magicNumberChosen = USD_CAD_MagicNumber;
                       }
                     //else
                     //   if(Symbol() == "US30.cash")
                     //     {
                     //      magicNumberChosen = 13.7665;
                     //     }
                     else
                       {
                        magicNumberChosen = 1;
                       }

   const double pips = (MathAbs(curr_Bid - curr_SL)*MathPow(10,_Digits));

   const double result = NormalizeDouble((amt_to_risk/(magicNumberChosen*pips)),2);


//Print("tHE PIPS: "+pips);

//Print("Normalized: "+ NormalizeDouble((amt_to_risk/(XAU_USD_MagicNumber*pips)),2));
   return result;
  }
//+------------------------------------------------------------------+
















//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CodeNotUsedForNow()
  {
//// Solution to conflict between confluences: At least 4 confluences need to agree.
////ConfluenceTeam[0] ==1 && ConfluenceTeam[1] ==1 && ConfluenceTeam[2] ==1 && ConfluenceTeam[3] ==1 && ConfluenceTeam[4]==1
//
//
//
////Print("suppResPrice[4]"+suppResPrice[4]+" ask: "+Ask);
//
////            Lesson from Lots and Position Volume: for 3,000 USD 0.2 lots is good, then for 20,000 USD it's 1.2 lots and
////            finally for 100,000 usd it's 6 lots. <<< It's huge I know.
//
////     ****************************************      Entry Rules         *********************************************** //
//// Going up: Entry 1
//// Let us try Break of structure centered trades. But also followed by at least one trend Confluence
//   if(ENTRY_1_ALLOWED == true && ConfluenceTeam[0] ==1 && ConfluenceTeam[2]==1 && ConfluenceTeam[6] ==1 && ConfluenceTeam[5] ==1
//      && ConfluenceTeam[3] ==1 && ConfluenceTeam[7] == 1 && ConfluenceTeam[14]==1)
//     {
//      //      // At lest 3 needs to be the same as the first one or at least 4 needs to be different
//      //      if(yesCounting>=3 || noCounting>=4)
//      //        {
//      //
//      //
//      //        }
//      if(suppResPrice[3] !=0 || Ask > suppResPrice[3])
//        {
//         // The takeProfit needs to be at least 3 times the SL if the Daily Support TP is too close from the entry
//         if(((suppResPrice_2[4] - Ask)*MathPow(10,_Digits)) < 3*((Ask-suppResPrice[3])*MathPow(10,_Digits)))
//           {
//            // TP Solutions
//            if(suppResPrice_2[5]==0)
//              {
//               // if the SL is too close from the entry take the one below.
//               if((Ask - suppResPrice[3]) < 150*_Point)
//                 {
//                  if(suppResPrice[2] <= 0)
//                    {
//                     // if new SL doesn't exist
//                     trade.Buy(6,NULL,Ask,(dcs_low[1]+50*_Point),suppResPrice_2[4],"Entry #1");
//                     //Print("Buy From the One Buy Buy");
//                     buyCheck = true;
//
//                     checker_EntryFirst = false;
//                     checker_EntryFirst_2 = true;
//                     //changeSLBuying(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//                    }
//                  else
//                    {
//                     // else the normal SL here is okay
//                     trade.Buy(6,NULL,Ask,suppResPrice[2],suppResPrice_2[4],"Entry #1");
//                     //Print("Buy From the One Buy Buy");
//                     buyCheck = true;
//
//                     checker_EntryFirst = false;
//                     checker_EntryFirst_2 = true;
//                     //changeSLBuying(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//                    }
//
//
//                 }
//               else
//                 {
//                  trade.Buy(6,NULL,Ask,suppResPrice[3],suppResPrice_2[4],"Entry #1");
//                  //Print("Buy From the One Buy Buy");
//                  buyCheck = true;
//
//                  checker_EntryFirst = false;
//                  checker_EntryFirst_2 = true;
//                  //changeSLBuying(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//                 }
//
//
//               //sellCheck = false;
//
//              }
//
//
//            trade.Buy(6,NULL,Ask,suppResPrice[3],suppResPrice_2[5],"Entry #1");
//            //Print("Buy From the One Buy Buy");
//            buyCheck = true;
//
//
//            //Print("This BufferTKR["+1+"]: "+ BufferTKR[1] + " BufferBKR["+1+"]: "+BufferBKR[1]);
//            checker_EntryFirst = false;
//            checker_EntryFirst_2 = true;
//            //changeSLBuying(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//            //TraillingStopLoss(Bid,(SuppResTestArray[3]));
//            //getPeriod = PERIOD_M5;
//            //sellCheck = false;
//
//           }
//         // else trade normally from daily level to daily level TP
//         else
//           {
//            trade.Buy(6,NULL,Ask,suppResPrice[3],suppResPrice_2[4],"Entry #1");
//            //Print("Buy From the One Buy Buy");
//            buyCheck = true;
//
//
//            //Print("This BufferTKR["+1+"]: "+ BufferTKR[1] + " BufferBKR["+1+"]: "+BufferBKR[1]);
//            checker_EntryFirst = false;
//            checker_EntryFirst_2 = true;
//            //changeSLBuying(rates[1].close, PositionGetDouble(POSITION_PRICE_OPEN));
//            //TraillingStopLoss(Bid,(SuppResTestArray[3]));
//            //getPeriod = PERIOD_M5;
//
//           }
//
//        }
//
//      //return buyCheck;}
//     }
////ConfluenceTeam[0] ==0 && ConfluenceTeam[1] ==0 && ConfluenceTeam[2] ==0 && ConfluenceTeam[3] ==0 && ConfluenceTeam[4]==0
////Print("suppResPrice[3]"+suppResPrice[3]+" bid: "+Bid);
//
//// Going down: Entry 1
//
////  Let us try Break of structure centered trades. But also followed by at least one trend Confluence
//   if(ENTRY_1_ALLOWED == true && ConfluenceTeam[1] ==0 && ConfluenceTeam[2]==0 && ConfluenceTeam[14]==1
//      && ConfluenceTeam[6] ==0 && ConfluenceTeam[5] ==0 && ConfluenceTeam[3] ==0 && ConfluenceTeam[7] == 0
//     )
//     {
//      // At lest 3 needs to be the same as the first one or at least 4 needs to be different
//      if(yesCounting>=3 || noCounting>=4)
//        {
//
//
//        }
//      if(suppResPrice[4] !=0 || Bid < suppResPrice[4])
//        {
//         //The takeProfit needs to be at least 3 times the SL if the Daily Support TP is too close from the entry
//         if(((Bid - suppResPrice_2[3])*MathPow(10,_Digits)) < 3*((suppResPrice[4] - Bid)*MathPow(10,_Digits)))
//           {
//            //if the SL is too close from the entry take the one above.
//            if((suppResPrice[4] - Bid) < 150*_Point)
//              {
//               if(suppResPrice[5] <= 0)
//                 {
//                  trade.Sell(6,NULL,Bid,(dcs_up[1] - 50*_Point),(suppResPrice_2[2]),"Entry #1");
//                  //Print("Sell From the One Sell Sell ");
//
//                  sellCheck = true;
//
//                  //changeSLSelling(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//                  checker_EntryFirst = true;
//                  checker_EntryFirst_2 = false;
//                 }
//               else
//                 {
//                  trade.Sell(6,NULL,Bid,suppResPrice[5],(suppResPrice_2[2]),"Entry #1");
//                  //Print("Sell From the One Sell Sell ");
//
//                  sellCheck = true;
//
//                  //changeSLSelling(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//                  checker_EntryFirst = true;
//                  checker_EntryFirst_2 = false;
//                 }
//
//              }
//            else
//              {
//               trade.Sell(6,NULL,Bid,suppResPrice[4],(suppResPrice_2[2]),"Entry #1");
//               //Print("Sell From the One Sell Sell ");
//
//               sellCheck = true;
//
//               //changeSLSelling(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//               checker_EntryFirst = true;
//               checker_EntryFirst_2 = false;
//              }
//
//
//
//           }
//         //else trade normally from daily level to daily level TP
//         else
//           {
//            trade.Sell(6,NULL,Bid,suppResPrice[4],(suppResPrice_2[3]),"Entry #1");
//            //Print("Sell From the One Sell Sell okay okay okay ");
//            sellCheck = true;
//
//            //Print("Difference: "+(rates[1].close - Bid)*_Digits+" DIGITS: "+_Digits+" BID: "+Bid);
//            //changeSLSelling(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//            checker_EntryFirst = true;
//            checker_EntryFirst_2 = false;
//            //TraillingStopLoss(Bid,(SuppResTestArray[4]));
//            getPeriod = PERIOD_M5;
//            //<<< Happening on a 5 Min Timframe  >>>> //
//           }
//
//        }
//
//
//      if(sellCheck == true)
//        {
//         //TraillingStopLoss(PositionGetDouble(POSITION_SL),(PositionGetDouble(POSITION_SL) - 30*_Point));
//         counterBuyPos += 1;
//         //Print("DifferenceSSSS: "+(rates[1].close - Bid)*_Digits+" DIGITS: "+_Digits+" BID: "+Bid);
//         //changeSLSelling(rates[1].close,PositionGetDouble(POSITION_SL));
//         //TraillingStopLoss(Bid,(SuppResTestArray[4]));
//         //Print("sELL BROWSKI ");
//
//        }
//      else
//         if(buyCheck == true)
//           {
//            //Print("BUYYY BROWSKI ");
//            //TraillingStopLoss(PositionGetDouble(POSITION_PRICE_OPEN),(PositionGetDouble(POSITION_SL) + 30*_Point));
//           }
//
//
//      //if(Pos)
//      //   //Print("This BufferTKR["+1+"]: "+ BufferTKR[1] + " BufferBKR["+1+"]: "+BufferBKR[1]);
//      checker_EntrySec = true;
//      checker_EntrySec_2 = false;
//      //return sellCheck;
//     }
//
//
//
//
/////         ========================= Entry Rule #2 ==================================   ///
//
//// Going up
//// Let us try Break of structure centered trades. This is essentially Break of Structure Entry.
//   if(ENTRY_2_ALLOWED == true &&ConfluenceTeam[2]==1 && ConfluenceTeam[6] ==1 && ConfluenceTeam[5] ==1 && ConfluenceTeam[3] ==1 && ConfluenceTeam[14]==1
//      && ConfluenceTeam[7] == 1 && ConfluenceTeam[9] ==1)
//     {
//      if(suppResPrice[3] !=0 || Ask > suppResPrice[3])
//        {
//
//         // if the SL is too close from the entry take the one below.
//         if((Ask - suppResPrice[3]) < 150*_Point && suppResPrice[2] > 0)
//           {
//            // if the TP does not exist then take the value from Donch Ind.
//            // TP problems solutions
//            if(suppResPrice[5] <= 0)
//              {
//               trade.Buy(6,NULL,Ask,suppResPrice[2],(dcs_up[1] - 50*_Point),"Entry #2");
//               //Print("Buy Buy Buy"+" lowerRates[1]: "+rates[1].close);
//               buyCheck = true;
//
//
//
//               checker_EntrySec = false;
//               checker_EntrySec_2 = true;
//               //changeSLBuying(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//              }// else you can continue with that precise Supp/Resi line as TP: suppResPrice[5]
//            else
//              {
//               // SL solutions
//               trade.Buy(6,NULL,Ask,suppResPrice[2],suppResPrice[5],"Entry #2");
//               //Print("Buy Buy Buy"+" lowerRates[1]: "+rates[1].close);
//               buyCheck = true;
//
//
//
//               checker_EntrySec = false;
//               checker_EntrySec_2 = true;
//               //changeSLBuying(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//              }
//
//
//           }
//         else
//           {
//            // else you can continue with that precise Supp/Resi line as SL: suppResPrice[3]
//            trade.Buy(6,NULL,Ask,suppResPrice[3],suppResPrice[5],"Entry #2");
//            //Print("Buy Buy Buy"+" lowerRates[1]: "+rates[1].close);
//            buyCheck = true;
//
//
//
//            checker_EntrySec = false;
//            checker_EntrySec_2 = true;
//            //changeSLBuying(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//           }
//
//        }
//
//
//     }
//
//// Going down
////  Let us try Break of structure centered trades. This is essentially Break of Structure Entry.
//   if(ENTRY_2_ALLOWED == true && ConfluenceTeam[2]==0 && ConfluenceTeam[6] ==0 && ConfluenceTeam[5] ==0&& ConfluenceTeam[14]==1
//      && ConfluenceTeam[3] ==0 && ConfluenceTeam[7] == 0 && ConfluenceTeam[9] ==1)
//     {
//
//      if(suppResPrice[4] !=0 || Bid < suppResPrice[4])
//        {
//
//
//         // if the SL is too close from the entry take the one above.
//         if((suppResPrice[4] - Bid) < 150*_Point && suppResPrice[5] > 0)
//           {
//            // if the TP does not exist then take the value from Donch Ind.
//            // TP problems solutions
//            if(suppResPrice[2] <= 0)
//              {
//               trade.Sell(6,NULL,Bid,suppResPrice[5],(dcs_low[1] + 50*_Point),"Entry #2");
//               //Print("Sell From the One Sell Sell Caution Caution Caution ");
//               sellCheck = true;
//               //counterBuyPos += 1;
//               //changeSLSelling(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//               checker_EntrySec = true;
//               checker_EntrySec_2 = false;
//              }// else you can continue with that precise Supp/Resi line as TP: suppResPrice[2]
//            else
//              {
//               // SL solutions
//               trade.Sell(6,NULL,Bid,suppResPrice[5],(suppResPrice[2]),"Entry #2");
//               //Print("Sell From the One Sell Sell Caution Caution Caution ");
//               sellCheck = true;
//               //counterBuyPos += 1;
//               //changeSLSelling(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//               checker_EntrySec = true;
//               checker_EntrySec_2 = false;
//              }
//
//
//
//           }
//         else
//           {
//            // else you can continue with that precise Supp/Resi line as SL: suppResPrice[4]
//            trade.Sell(6,NULL,Bid,suppResPrice[4],(suppResPrice[2]),"Entry #2");
//            //Print("Sell From the One Sell Sell Caution Caution Caution ");
//
//            sellCheck = true;
//            //counterBuyPos += 1;
//            //changeSLSelling(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//            checker_EntrySec = true;
//            checker_EntrySec_2 = false;
//           }
//
//
//        }
//
//
//
//
//     }
//   for(i=PositionsTotal(); i>=0; i--)
//     {
//      // start of loop
//      if(Symbol()==PositionGetSymbol(i))
//        {
//         // get ticket number
//         ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
//         //get current stop loss
//         double currentStopLoss = PositionGetDouble(POSITION_SL);
//
//         //if there is an open buy position
//         if(PositionSelect(Symbol())==true && PositionGetInteger(POSITION_TYPE) == 0)
//           {
//            // Needs to be Entry 1 or Entry 2. Not made for Entry 3.
//            if(PositionGetString(POSITION_COMMENT) =="Entry #1" || PositionGetString(POSITION_COMMENT) =="Entry #2")
//              {
//               changeSLBuying(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//               //Print("there is an open position right now????? ");
//              }
//
//
//            ////Modify Stpo loss
//            //trade.PositionModify(PositionTicket,NewStopLoss,PositionGetDouble(POSITION_TP));
//           }
//         // if there is an open sell position
//         if(PositionSelect(Symbol())==true && PositionGetInteger(POSITION_TYPE) == 1)
//           {
//            if(PositionGetString(POSITION_COMMENT) =="Entry #1" || PositionGetString(POSITION_COMMENT) =="Entry #2")
//              {
//               //Print("Changed from here; changeSL Selling modify again");
//               changeSLSelling(rates[1].close,PositionGetDouble(POSITION_PRICE_OPEN));
//              }
//
//           }
//        }
//     }// end of for loop


//Print("postion type: "+PositionGetInteger(POSITION_TYPE));

//      if(HistoryOrderSelect(ticket) == true)
//        {
//
//         reason = HistoryOrderGetInteger(ticket, ORDER_REASON);
//        }
//
//
//      if(EnumToString(reason) == "ORDER_REASON_SL")
//        {
//         //Print("ticket ", ticket, "  triggered SL");
//        }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
