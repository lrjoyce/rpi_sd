#include "DemoApp.h"

configuration DemoAppC
{
}
implementation
{
	components DemoP, MainC, new HamamatsuS10871TsrC() as PhotoC;
	components new Msp430InternalTemperatureC() as InternalTempC;
	components new SensirionSht11C() as TempC;
	components new SensirionSht11C() as HumidityC;
	components ActiveMessageC, new AMSenderC(AM_DEMO_MESSAGE);
	components SerialActiveMessageC as SerialC;
	components LedsC;
	components new TimerMilliC();
	
	DemoP.Boot     -> MainC;
	DemoP.Photo    -> PhotoC;
	DemoP.IntTemp  -> InternalTempC;
        DemoP.Temp     -> TempC.Temperature;
        DemoP.Humidity -> HumidityC.Humidity;

	DemoP.RadioControl -> ActiveMessageC;
	DemoP.AMSend -> AMSenderC;
	DemoP.Packet -> ActiveMessageC;

	DemoP.SerialControl -> SerialC;
  	DemoP.SerialAMSend -> SerialC.AMSend[AM_DEMO_MESSAGE];
  	DemoP.SerialPacket -> SerialC;

	DemoP.Leds -> LedsC;
	DemoP.Timer -> TimerMilliC;
}
