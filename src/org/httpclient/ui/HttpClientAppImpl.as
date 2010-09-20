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
    public var responseBody:String;    
    
    // Components
    public var serverInput:TextInput;
    public var customInput:TextInput;

    public function onCreationComplete(event:Event):void {      
      //Security.loadPolicyFile("xmlsocket://domain.com:5001");
    }

    public function onCustomRequest(event:Event):void {
        sendHttp(customInput.text);
    }

    public function onSubtitles(event:Event):void {
        sendHttp("/subtitles");
    }

    public function onPlay(event:Event):void {
        sendHttp("/play");
    }

    public function onPause(event:Event):void {
        sendHttp("/pause");
    }

    public function sendHttp(path:String):void {
      
      responseBody = "";
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
          status = "Received " + e.bytes.length + " bytes";
          responseBody += e.readUTFBytes();
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
      
      status = "Connecting";
      status = serverInput.text + path;
      
      var client:HttpClient = new HttpClient();
      client.timeout = 5000;
      client.listener = new HttpListener(listeners);
      
      client.request(new URI(serverInput.text + path), new Get());
    }
    
  }

}
