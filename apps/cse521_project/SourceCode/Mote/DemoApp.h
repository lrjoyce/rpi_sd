#ifndef __DEMOAPP_H
#define __DEMOAPP_H

enum
{
	AM_DEMO_MESSAGE = 150,
};

typedef nx_struct demo_message
{
	nx_int8_t   moteId;
	nx_uint16_t photoReading;
	nx_uint16_t tempReading;
	nx_uint16_t humidityReading;
	nx_uint16_t internalTempReading;
} demo_message_t;

#endif // __DEMOAPP_H
