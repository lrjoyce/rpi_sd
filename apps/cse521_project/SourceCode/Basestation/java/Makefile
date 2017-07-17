BUILD_EXTRA_DEPS = Main.class

Main.class: DemoAppMsg.java
	javac *.java 

DemoAppMsg.java: ../DemoApp.h
	nescc-mig java -java-classname=DemoAppMsg ../DemoApp.h demo_message -o $@

clean:
	rm -f DemoAppMsg.java  *.class
