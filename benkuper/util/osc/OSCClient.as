package benkuper.util.osc 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.IPVersion;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	
	import benkuper.util.IPUtil;
	
	import org.tuio.connectors.UDPConnector;
	import org.tuio.osc.IOSCListener;
	import org.tuio.osc.OSCManager;
	import org.tuio.osc.OSCMessage;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class OSCClient extends EventDispatcher implements IOSCListener 
	{
		public var id:String;
		private var port:int;
		
		private var oscM:OSCManager;
		
		public static var availableServers:Vector.<OSCServerInfo>;

		private var listener:IOSCListener;
		
		public function OSCClient(id:String, listener:IOSCListener, port:int = 0) 
		{
			
			if (availableServers == null) availableServers = new Vector.<OSCServerInfo>();
			
			this.id = id;
			this.listener = listener;
			
			if (port == 0) port = int(30000 + Math.random() * 20000);
			this.port = port;
			oscM = new OSCManager(new UDPConnector("0.0.0.0", port), new UDPConnector("0.0.0.0", 0,  false, false));
			oscM.addMsgListener(this);
			trace("OSC Client bound on port :", port);
			
			
		}		
		
		public function yo(type:String = ""):void
		{
			availableServers = new Vector.<OSCServerInfo>();
			
			var msg:OSCMessage = new OSCMessage();
			msg.address = "/yo";
			msg.addArgument("s", IPUtil.getLocalIP());
			msg.addArgument("i", port);
			if (type != "") msg.addArgument("s", type);
			broadcast(msg, 10000); //master port
		}
		
		public function register(type:String = ""):void
		{
			var msg:OSCMessage = new OSCMessage();
			msg.address = "/register";
			msg.addArgument("s", id);
			msg.addArgument("s", IPUtil.getLocalIP());
			msg.addArgument("i", port);
			broadcast(msg, 10000); //master port
		}
		
		public function unregister(type:String = ""):void
		{
			var msg:OSCMessage = new OSCMessage();
			msg.address = "/unregister";
			msg.addArgument("s", id);
			broadcast(msg, 10000); //master port
		}
		
		public function addServer(serverID:String, serverType:String, serverIP:String,serverPort:int):void
		{
			var s:OSCServerInfo = getServer(serverID, serverIP);
			if (s == null) 
			{	
				s = new OSCServerInfo(serverID, serverType, serverIP, serverPort);
				availableServers.push(s);
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function getServer(serverID:String, serverIP:String):OSCServerInfo
		{
			for each(var s:OSCServerInfo in availableServers)
			{
				if (s.id == serverID && s.ip == serverIP) return s;
			}
			
			return null;
		}
		
		public function broadcast(msg:OSCMessage,port:int):void
		{
			var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			
			for each(var i:NetworkInterface in interfaces)
			{
				for each(var a:InterfaceAddress in i.addresses)
				{
					if (a.ipVersion == IPVersion.IPV4 && a.broadcast != "") oscM.sendOSCPacketTo(msg, a.broadcast, port);
				}
			}
		}
		
		/* INTERFACE org.tuio.osc.IOSCListener */
		
		public function acceptOSCMessage(msg:OSCMessage):void 
		{
			var command:String = msg.address.split("/")[1];
			
			switch(command)
			{
				case "yoyo":
					var serverIP:String = msg.arguments[0] as String;
					var numServers:int = msg.arguments[1] as int;
					
					for(var i:int=0;i<numServers;i++)
					{
						var serverID:String = msg.arguments[2 + (i * 3)] as String;
						var serverType:String =  msg.arguments[2 + (i * 3) + 1] as String;
						var serverPort:int =  msg.arguments[2 + (i * 3) + 2] as int;
						addServer(serverID, serverType, serverIP, serverPort);
					}
					break;
					
				default:
					listener.acceptOSCMessage(msg);
					break;
			}
		}
		
	}

}