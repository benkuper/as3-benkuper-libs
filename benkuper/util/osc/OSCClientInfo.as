package benkuper.util.osc 
{
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class OSCClientInfo
	{
		public var id:String;
		public var ip:String;
		public var port:int;
		
		public function OSCClientInfo(id:String, ip:String, port:int):void
		{
			this.id = id;
			this.ip = ip;
			this.port = port;
			
			trace("New OSCClient Info :", this);
		}
		
		public function toString():String
		{
			return "[OSCClientInfo : " + id + " > " + ip + ":" + port + "]";
		}
	}
}