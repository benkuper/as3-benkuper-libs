package benkuper.util.osc 
{
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class OSCServerInfo 
	{
		public var id:String;
		public var type:String;
		
		public var ip:String;
		public var port:int;
		
		public function OSCServerInfo(id:String,type:String,ip:String,port:int) 
		{
			this.port = port;
			this.ip = ip;
			this.type = type;
			this.id = id;
			
		}
		
		
		public function toString():String
		{
			return "[OSCClientInfo : " + id + " ("+type+") > " + ip + ":" + port + "]";
		}
	}

}