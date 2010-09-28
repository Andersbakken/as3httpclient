package org.httpclient.ui {

  import flash.system.*;
  import mx.controls.*;
  import mx.containers.*;
  import flash.events.*;
  import mx.core.Application;
  import mx.events.MenuEvent;
  import flash.utils.ByteArray;
  import mx.collections.ArrayCollection;

  import org.httpclient.*;
  import org.httpclient.http.*;
  import org.httpclient.events.*;
  import com.adobe.net.URI;
  import com.adobe.utils.StringUtil;

  public class HttpClientAppImpl extends Application {

    [Bindable]
    public var status:String = "";

    [Bindable]
    public var responseStatus:String;

    [Bindable]
    public var debug:String = "";

    [Bindable]
    public var currentEvent:String;

    [Bindable]
    public var currentEventID:String;

    [Bindable]
    public var deviceInfo:String;

    //[Bindable]
    //public var latency:String;

    // Components
    public var serverInput:TextInput;
    public var customInput:TextInput;
    public var eventLabel:Label;

    public function onCreationComplete(event:Event):void {
        Log.level = Log.DEBUG;
        Log.output = function(s:String):void { debug = debug + s + "\n"; };
        //debug = "balle\n";
        Log.debug("fisk");
        reconnect();
    }

    public function setCurrentEvent(str:String):void
    {
        var xml:XML = new XML(str);

        currentEventID = xml.attribute("id");
        currentEvent = xml;
        //var date:Date = new Date();
        //latency = (date.valueOf() - xml.attribute("time"));
    }

    public function setDeviceInfo(str:String):void
    {
        var xml:XML = new XML(str);
        var a:XMLList = xml.@*;
        var data:String = "";
        for (var i:int = 0; i < a.length(); i++) 
            data += a[i].name() + ": " + xml.attribute(a[i].name()) + "\n";

        deviceInfo = data;
    }
    public function onCustomRequest(event:Event):void { sendHttp(customInput.text, setCurrentEvent); }
    public function onEvents(event:Event):void { reconnect(); }
    public function onPlay(event:Event):void { sendHttp("/mediacontrol/play", null); }
    public function onPause(event:Event):void { sendHttp("/mediacontrol/pause", null); }
    public function onDeviceInfo(event:Event):void { sendHttp("/device?format=xml", setDeviceInfo); }
    public function reconnect():void { sendHttp("/events?format=xml", setCurrentEvent); }

    public function sendHttp(path:String, output:*):void {

      responseStatus = "";

      var listeners:Object = {
        onConnect: function(e:HttpRequestEvent):void {
          status = "Connected";
        },
        onRequest: function(e:HttpRequestEvent):void {
          status = "Request sent";
        },
        onStatus: function(e:HttpStatusEvent):void {
          status = "Got response header";
          responseStatus = e.code + " " + e.response.message;
        },
        onData: function(e:HttpDataEvent):void {
          var str:String = e.readUTFBytes();
          if (output is Function) {
              output(str);
          } else if (output is String) {
              output = str;
          }
        },
        onClose: function():void {
          status = "Closed";
        },
        onComplete: function(e:HttpResponseEvent):void {
          status = "Completed";
        },
        onError: function(event:ErrorEvent):void {
          status = "Error: " + event.text;
        }
      };

      //status = "Connecting";
      status = serverInput.text + path;

      var client:HttpClient = new HttpClient(null, 0); // 0-timeout

      //client.timeout = 5000;
      client.listener = new HttpListener(listeners);

      client.request(new URI(serverInput.text + path), new Get());
    }

  }

}
