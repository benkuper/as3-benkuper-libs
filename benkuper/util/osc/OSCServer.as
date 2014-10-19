package benkuper.util.osc 
{
	import benkuper.util.IPUtil;
	import flash.net.InterfaceAddress;
	import flash.net.IPVersion;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.utils.ByteArray;
	import org.tuio.connectors.UDPConnector;
	import org.tuio.osc.IOSCListener;
	import org.tuio.osc.OSCManager;
	import org.tuio.osc.OSCMessage;
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class OSCServer implements IOSCListener
	{
		[Embed(source="server_definitions.xml", mimeType="application/octet-stream")]
		private static var defClass:Class;
		public static var serversDefinitions:XML;
		
		private static var isInit:Boolean;
		private static var instances:Vector.<OSCServer>;
		
		private static var master:OSCServer; // The service dispatcher
		private var processFunc:Function;
		
		public var id:String;
		public var type:String;
		public var port:int;
		
		private var oscM:OSCManager;
		private var registeredObjects:Array;
		
		private var clients:Vector.<OSCClientInfo>
		
		public function OSCServer(id:String,type:String = "none") 
		{
			if (!isInit) init();
			this.id = id;
			this.type = type;
			this.port = int(getDefinitionForType(type).@port);
			
			processFunc = processMessageMaster;
			
			if (id != "master")
			{
				instances.push(this);
				processFunc = processMessage;
				
			}
			
			clients = new Vector.<OSCClientInfo>();
			
			registeredObjects = new Array();
			
			oscM = new OSCManager(new UDPConnector("0.0.0.0", port), new UDPConnector("0.0.0.0", 0, false, false)); //0.0.0.0 = all interfaces
			oscM.addMsgListener(this);
			
			trace("Created OSC Server :" + id + " on port :" + port);
		}
		
		public static function init():void
		{
			if (isInit) return;
			isInit = true;
			
			instances = new Vector.<OSCServer>();
			
			var ba:ByteArray = new defClass() as ByteArray;
			serversDefinitions = new XML(ba.readUTFBytes(ba.bytesAvailable));
			
			master = new OSCServer("master", "master");
			
			
		}
		
		public static function create(id:String, type:String = "none"):OSCServer
		{
			if (!isInit) init();
			var s:OSCServer = getServerByID(id);
			if (s == null) s = new OSCServer(id, type);
			return s;
		}
		
		public function destroy():void
		{
			instances.splice(instances.indexOf(this), 1);
		}
		
		
		public static function getServerByID(id:String):OSCServer
		{
			for each(var s:OSCServer in instances)
			{
				if (s.id == id) return s;
			}
			
			return null;
		}
		
		public static function getDefinitionForType(type:String):XML
		{
			return serversDefinitions.server.(@type == type)[0];
		}
		
		public static function getServersByType(type:String):Vector.<OSCServer>
		{
			var result:Vector.<OSCServer> = new Vector.<OSCServer>();
			for each(var s:OSCServer in instances)
			{
				if (s.type == type) result.push(s);
			}
			
			return result;
		}
		
		
		//Registering and sending
		public function addListener(address:String,listener:IOSCListener):void
		{
			if (getRegisteredObject(address, listener) != null)
			{
				trace("Already registered !");
				return;
			}
			
			registeredObjects.push( { address:address, listener:listener } );
		}
		
		public function removeListener(address:String,listener:IOSCListener):void
		{
			while (getRegisteredObject(address, listener) != null)
			{
				registeredObjects.splice(registeredObjects.indexOf(getRegisteredObject(address, listener)), 1);
			}
		}
		
		public function getRegisteredObject(address:String, listener:IOSCListener):Object
		{
			for each(var o:Object in registeredObjects)
			{
				if (o.address == address && o.listener == listener) return o;
			}
			
			return null;
		}
		
		public function sendTo(msg:OSCMessage, host:String, port:int):void
		{			
			try
			{
				oscM.sendOSCPacketTo(msg, host, port);
			} catch (err:Error)
			{
				trace("[OSCMaster] L'osc est mal configuré, impossible d'envoyer !");
			}
		}
		
		public function broadcast(msg:OSCMessage,port:int):void
		{
			var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			
			for each(var i:NetworkInterface in interfaces)
			{
				for each(var a:InterfaceAddress in i.addresses)
				{
					if (a.ipVersion == IPVersion.IPV4) sendTo(msg, a.broadcast, port);
				}
			}
		}
		
		
		
		
		/* INTERFACE org.tuio.osc.IOSCListener */
		
		public function acceptOSCMessage(msg:OSCMessage):void 
		{
			processFunc.apply(null, [msg]);
		}
		
		private function processMessage(msg:OSCMessage):void 
		{
			var addSplit:Array = msg.address.split("/");
			var first:String = addSplit[1];
			var clientID:String = msg.arguments[0];
			
			switch(first)
			{
			case "register":
				registerClient(clientID, msg.arguments[1] as String, msg.arguments[2] as int);
				break;
				
			case "unregister":
				unregisterClient(clientID);
				break;
				
			case "ping": //asked for a ping
				var c:OSCClientInfo = getClientInfo(clientID);
				var msg:OSCMessage = new OSCMessage();
				msg.address = "/pong";
				msg.addArgument("s", id);
				if (c != null) sendTo(msg, c.id, c.port);
				break;
				
			case "pong":
				break;
				
			default:
				dispatchMessage(msg);
				break;
			}
		}
		
		
		private function registerClient(clientID:String, clientIP:String, clientPort:int):void 
		{
			trace("Register client");
			if (getClientInfo(clientID) != null)
			{
				trace("Client with same ID already exists !");
				return;
			}
			
			clients.push(new OSCClientInfo(clientID, clientIP, clientPort));
		}
		
		private function unregisterClient(clientID:String):void 
		{
			trace("Unregister client");
			var c:OSCClientInfo = getClientInfo(clientID);
			if (c != null) clients.splice(clients.indexOf(c), 1);
		}
		
		private function getClientInfo(clientID:String):OSCClientInfo
		{
			for each(var c:OSCClientInfo in clients)
			{
				if (c.id == clientID) return c;
			}
			
			return null;
		}
		
		
		private function dispatchMessage(msg:OSCMessage):void 
		{
			for each(var o:Object in registeredObjects)
			{
				var match:Boolean = msg.address.match(o).length > 0;
				if (match) (o.listener as IOSCListener).acceptOSCMessage(msg);
			}
		}
		
		
		//MASTER
		
		private function processMessageMaster(msg:OSCMessage):void 
		{
			var addSplit:Array = msg.address.split("/");
			var checkAddress:String = addSplit[1];
			
			if (checkAddress == "yo") //YO protocol (custom Bonjour-like OSC auto-discovery)
			{
				var remoteIP:String = msg.arguments[0] as String;
				var remotePort:int = msg.arguments[1] as int;
				var type:String = "";
				if (msg.arguments.length > 2) type == msg.arguments[2];
				
				//answer back to the caller, give list of local servers
				var servers:Vector.<OSCServer> = OSCServer.instances;
				if (type != "") servers = OSCServer.getServersByType(type);
				
				var msg:OSCMessage = new OSCMessage();
				msg.address = "/yoyo"; //answer message
				msg.addArgument("s", IPUtil.getLocalIPOfInterface(remoteIP)); // to change
				msg.addArgument("i", servers.length);
				
				for each(var s:OSCServer in servers)
				{
					msg.addArgument("s", s.id);
					msg.addArgument("s", s.type);
					msg.addArgument("i", s.port);
				}
				
				sendTo(msg, remoteIP, remotePort);
			}
		}
	}

}