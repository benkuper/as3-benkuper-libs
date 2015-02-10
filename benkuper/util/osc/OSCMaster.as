package benkuper.util.osc  
{
	import benkuper.util.IPUtil;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.net.InterfaceAddress;
	import flash.net.IPVersion;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import org.tuio.connectors.UDPConnector;
	import org.tuio.osc.IOSCListener;
	import org.tuio.osc.OSCManager;
	import org.tuio.osc.OSCMessage;
	//import ui.Toaster;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class OSCMaster implements IOSCListener
	{
		public static var instance:OSCMaster;
		public var oscManagers:Vector.<OSCManager>;
		public var oscM:OSCManager;
		public var port:int;
		
		private var verbose:Boolean = true;
		
		public var registeredObjects:Array;
		
		public function OSCMaster(port:int = 15000) 
		{
			this.port = port;
			registeredObjects = new Array();
			
			oscManagers = new Vector.<OSCManager>();
			
			//var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			
			//for each(var i:NetworkInterface in interfaces)
			//{
				//for each(var a:InterfaceAddress in i.addresses)
				//{
					//if (a.ipVersion == IPVersion.IPV4 && a.address != "127.0.0.1") 
					//{
						//try
						//{
							//var om:OSCManager = new OSCManager(new UDPConnector(a.address, port), null);
							//om.addMsgListener(this);
							//oscManagers.push(om);
						//}catch (e:Error)
						//{
							//trace("Error bind ip :" +a.address);
						//}
					//}
				//}
			//}
			
			oscM = new OSCManager(new UDPConnector("0.0.0.0", port), new UDPConnector("0.0.0.0", 10000, false, false)); //0.0.0.0 = all interfaces
			oscM.addMsgListener(this);
			
		}
		
		public static function init(port:int = 15000):void
		{
			if (instance) return;
			instance = new OSCMaster(port);
		}
		
		public static function register(address:String,listener:IOSCListener):void
		{
			if (getRegisteredObject(address, listener) != null)
			{
				trace("Already registered !");
				return;
			}
			
			instance.registeredObjects.push( { address:address, listener:listener } );
		}
		
		public static function unregister(address:String,listener:IOSCListener):void
		{
			while (getRegisteredObject(address, listener) != null)
			{
				instance.registeredObjects.splice(instance.registeredObjects.indexOf(getRegisteredObject(address, listener)), 1);
			}
		}
		
		public static function getRegisteredObject(address:String, listener:IOSCListener):Object
		{
			for each(var o:Object in instance.registeredObjects)
			{
				if (o.address == address && o.listener == listener) return o;
			}
			
			return null;
		}
		
		public static function sendTo(msg:OSCMessage, host:String, port:int):void
		{
			if (instance.verbose)
			{
				//Toaster.info("send OSC :" + msg.address + " " + msg.argumentsToString());
				//trace("send OSC :", host, port, msg.address, msg.argumentsToString());
			}
			
			try
			{
				instance.oscM.sendOSCPacketTo(msg, host, port);
			} catch (err:Error)
			{
				//Toaster.error("[OSCMaster] L'osc est mal configuré, impossible d'envoyer !");
			}
		}
		
		public static function broadcast(msg:OSCMessage,port:int):void
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
		
		public static function broadcastFullFlood(msg:OSCMessage,port:int):void
		{
			var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			
			for each(var i:NetworkInterface in interfaces)
			{
				for each(var a:InterfaceAddress in i.addresses)
				{
					if (a.ipVersion == IPVersion.IPV4 && a.address != "127.0.0.1" && a.address.split(".")[0] != "169") 
					{
						var addSplit:Array = a.address.split(".");
						addSplit.pop()
						var baseAddress:String = addSplit.join(".");
						for (var g:int = 1; g < 255; g++)
						{
							sendTo(msg, baseAddress+"."+g, port);
						}
					}
				}
			}
		}
		
		/* INTERFACE org.tuio.osc.IOSCListener */
		public function acceptOSCMessage(msg:OSCMessage):void 
		{
			var checkAddress:String = msg.address.split("/")[1];
			
			for each(var o:Object in registeredObjects)
			{
				
				if (o.address == checkAddress) 
				{
					
					(o.listener as IOSCListener).acceptOSCMessage(msg);
				}
			}
		}
		
	}

}