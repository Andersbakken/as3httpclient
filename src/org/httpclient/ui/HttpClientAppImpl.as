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
    public var responseBody:String = "";
    
    [Bindable]
    public var currentEvent:String;    

    [Bindable]
    public var currentEventID:Number;    

    [Bindable]
    public var latency:Number;    

    // Components
    public var serverInput:TextInput;
    public var customInput:TextInput;
    public var eventLabel:Label;

    public function log(str:String):void
    {
        responseBody = str + "\n" + responseBody;
    }

    public function onCreationComplete(event:Event):void {      
        //log("foobar");
        //trace("balle");
        //Log.output = log;
        //Log.debug("this is a test");
      //Security.loadPolicyFile("xmlsocket://domain.com:5001");
      //event.backgroundColor = 0xDDDDDD;
    }

    public function setCurrentEvent(str:String):void 
    {
        //responseBody += str;
        //appendToResponseBody(str);
        var xml:XML = new XML(str);
        
        var date:Date = new Date();
        currentEventID = xml.attribute("id");
        currentEvent = xml;
        latency = (date.valueOf() - xml.attribute("time"));
    }
    public function appendToResponseBody(str:String):void { responseBody += str; }
    //public function onCustomRequest(event:Event):void { sendHttp(customInput.text, appendToResponseBody); }
    public function onCustomRequest(event:Event):void { sendHttp(customInput.text, setCurrentEvent); }
    public function onEvents(event:Event):void { sendHttp("/events?format=XML", setCurrentEvent); }
    public function onPlay(event:Event):void { sendHttp("/mediacontrol/play", appendToResponseBody); }
    public function onPause(event:Event):void { sendHttp("/mediacontrol/pause", appendToResponseBody); }

    public function sendHttp(path:String, output:Function):void {
      
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
          output(str);
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
