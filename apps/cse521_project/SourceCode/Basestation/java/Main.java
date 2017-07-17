import java.io.*;
import java.util.*;
import net.tinyos.message.*;
public class Main implements MessageListener
{
	MoteIF mote;
	PrintStream outputFile = null;
	
	public Main()
	{
		try 
		{
                        mote = new MoteIF();
                        mote.registerListener(new DemoAppMsg(), this);
                        System.out.println("Connection Successful");
                }
                catch(Exception e) {}
		try
                {
                        outputFile = new PrintStream(new FileOutputStream("output.txt"));
                }
                catch (Exception e){}
		
	}
	public void messageReceived(int dest, Message m)
        {
		// Interpret msg as a DemoAppMsg
		DemoAppMsg msg = (DemoAppMsg)m;

		// Create time string
		long epochTime = System.currentTimeMillis()/1000;
		
		// Most values need to be scaled from their uint valeus
		double x, y, z, internalTempC, tempC, humidity;
		x = msg.get_internalTempReading();
		y = msg.get_tempReading();
		z = msg.get_humidityReading(); 

		internalTempC = ((((x/4096.0)*1.5)-0.986)/0.00355);
		tempC         = -39.5   + 0.01*y;
		humidity      = -2.0468 + 0.0367*z - 0.0000015955*z*z;
		
		// Adjust humidity for temp
		humidity      = (tempC-25)*(0.01 + 0.00008*tempC) + humidity;
		// Get temp in F
		double tempF    = (1.8*tempC) + 32.0;
		double intTempF = (1.8*internalTempC) + 32.0;
		// Get photo reading. No scaling necessary
		double photo  = msg.get_photoReading();

		// Create map for mote numbers to rooms
		Map<Integer, String> moteLoc = new HashMap<Integer, String>();
		moteLoc.put(61, "MainFloorBedroom");
		moteLoc.put(62, "SecondFloorBedroom");
		moteLoc.put(60, "SunRoom");
		moteLoc.put(64, "Basement");
		moteLoc.put(8, "LivingArea");
		moteLoc.put(63, "Outside");
		moteLoc.put(67, "OutsideControl");

		String moteId;
		Byte b1 = msg.get_moteId();
		int moteI = b1.intValue();
		if (moteLoc.containsKey(moteI))
		{
			moteId = moteLoc.get(moteI);
		}
		else
		{
		        moteId = "unknownMote";	
		}

		// Create POST parameter string
		String post;
		post = "sensorId="     + moteId    +
		       "&timeStamp="   + epochTime +
	 	       "&temp="        + intTempF  +      
		       "&ambientTemp=" + tempF     +
		       "&light="       + photo     +
		       "&humidity="    + humidity;
		System.out.println(post);
	
		// Create command string, run it, read output
		String[] command = {"curl", "--data", post, "71.86.152.84/app.php/data/", "-u", "scott:melenbrink521"};
		if (tempF < 100.0 && tempF > 0.0 && humidity < 100.0 && humidity > 0.0)
		{
			try{
				Process p = Runtime.getRuntime().exec(command);
				BufferedReader in = new BufferedReader(
						new InputStreamReader(p.getInputStream()));
				String line = null;
				while ((line = in.readLine()) != null) {
					System.out.println(line);
				}
			} catch (IOException e) {
			    e.printStackTrace();
			}
		}
		else
		{
			System.out.println("Invalid data in packet: ");
			System.out.println(post);
		}
	}

	public static void main(String args[])
  	{
		new Main();
	}
}
