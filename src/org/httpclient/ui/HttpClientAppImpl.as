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
    public var requestSent:String = "";
    
    [Bindable]
    public var status:String = "";
  
    [Bindable]
    public var responseStatus:String;
    
    [Bindable]
    public var responseHeader:String;
    
    [Bindable]
    public var responseBody:String;    
    
    // Components
    public var uriInput:TextInput;
    public var tabNavigator:TabNavigator;

    public function onCreationComplete(event:Event):void {      
      //Security.loadPolicyFile("xmlsocket://domain.com:5001");
    }

    public function onRequest(event:Event):void {
      
      requestSent = "";
      responseBody = "";
      responseStatus = "";
      responseHeader = "";    
      
      var listeners:Object = { 
        onConnect: function(e:HttpRequestEvent):void {
          status = "Connected";
        },
        onRequest: function(e:HttpRequestEvent):void {
          status = "Request sent";
          requestSent = e.header.replace(/\r\n/g, "\n");
          if (e.request.body) requestSent += e.request.body;
        },
        onStatus: function(e:HttpStatusEvent):void {
          status = "Got response header";
          responseStatus = e.code + " " + e.response.message;
          responseHeader = e.header.toString();
        },
        onData: function(e:HttpDataEvent):void {           
          status = "Received " + e.bytes.length + " bytes";
          responseBody += e.readUTFBytes();
        },        
        onClose: function():void {
          status = "Closed";
          tabNavigator.selectedIndex = 1;
        },
        onComplete: function(e:HttpResponseEvent):void {          
          status = "Completed";
        },
        onError: function(event:ErrorEvent):void {
          status = "Error: " + event.text;
        }
      };
      
      status = "Connecting";
      
      var client:HttpClient = new HttpClient();
      client.timeout = 5000;
      client.listener = new HttpListener(listeners);
      
      client.request(new URI(uriInput.text), new Get());
    }
    
  }

}
