module DemoP
{
	uses interface Boot;

	uses interface Read<uint16_t> as Photo;
        uses interface Read<uint16_t> as IntTemp;
	uses interface Read<uint16_t> as Temp;
        uses interface Read<uint16_t> as Humidity;     

	uses interface SplitControl as RadioControl;
	uses interface AMSend;
	uses interface Receive;
	uses interface Packet;

	uses interface SplitControl as SerialControl;
        uses interface Packet as SerialPacket;
        uses interface AMSend as SerialAMSend;

	
	uses interface Leds;
	uses interface Timer<TMilli>;
}
implementation
{
	message_t buf;
	message_t *receivedBuf;

        uint16_t photoPayload    = 0;
	uint16_t intTempPayload  = 0;
	uint16_t tempPayload     = 0;
	uint16_t humidityPayload = 0;
	
	task void readSensors();
	task void sendPacket();
	task void sendSerialPacket();
	
	event void Boot.booted()
	{
		call RadioControl.start();
		call SerialControl.start();
	}
	
	event void RadioControl.startDone(error_t err)
	{
		if(TOS_NODE_ID != 0)
		{
			call Leds.led1Toggle();
			//call Timer.startPeriodic(307200);
			call Timer.startPeriodic(5096);
                }
	}
	
	task void readSensors()
	{
		demo_message_t * payload = (demo_message_t *)call Packet.getPayload(&buf, sizeof(demo_message_t));

		if(call Photo.read() != SUCCESS){
			post readSensors();
                }
		payload->photoReading = photoPayload;

		if(call IntTemp.read() != SUCCESS){
			post readSensors();
                }
		payload->internalTempReading = intTempPayload;

		if(call Temp.read() != SUCCESS){
			post readSensors();
                }
		payload->tempReading = tempPayload;

		if(call Humidity.read() != SUCCESS){
			post readSensors();
                }
		payload->humidityReading = humidityPayload;

		payload->moteId          = TOS_NODE_ID;
		post sendPacket();
	}
	
	event void Timer.fired()
	{
		post readSensors();
	}
	
	event void Photo.readDone(error_t err, uint16_t value)
	{
		if(err != SUCCESS)
			post readSensors();
		else
		{
			photoPayload = value;
		}
	}

	event void IntTemp.readDone(error_t err, uint16_t value)
	{
		if(err != SUCCESS)
			post readSensors();
		else
		{
			intTempPayload = value;
		}
	}
	
	event void Temp.readDone(error_t err, uint16_t value)
	{
		if(err != SUCCESS)
			post readSensors();
		else
		{
                        // Scale to Celsius
			tempPayload = value;
		}
	}

	event void Humidity.readDone(error_t err, uint16_t value)
	{
		if(err != SUCCESS)
			post readSensors();
		else
		{
			humidityPayload = value;
		}
	}

	task void sendPacket()
	{
		if(call AMSend.send(AM_BROADCAST_ADDR, &buf, sizeof(demo_message_t)) != SUCCESS){
			call Leds.led1Toggle();
			post sendPacket();
		}
	}

	task void sendSerialPacket()
	{
		if(call SerialAMSend.send(AM_BROADCAST_ADDR, receivedBuf, sizeof(demo_message_t)) != SUCCESS)
			post sendSerialPacket();
	}	
	
	event void AMSend.sendDone(message_t * msg, error_t err)
	{
		if(err != SUCCESS)
			post sendPacket();
	}
	
	event message_t * Receive.receive(message_t * msg, void * payload, uint8_t len)
	{
		if (TOS_NODE_ID == 0)
		{
			demo_message_t * demoPayload = (demo_message_t *)payload;
			call Leds.led1Toggle();
			receivedBuf = msg;
			post sendSerialPacket();
			return msg;
		}
		else
		{
			return msg;
		}
	}

	event void SerialAMSend.sendDone(message_t* ptr, error_t success) 
	{
		if(success!=SUCCESS)
			post sendSerialPacket();
    	}
	event void SerialControl.startDone(error_t err){}
	event void RadioControl.stopDone(error_t err) {}
	event void SerialControl.stopDone(error_t err) {}
}
