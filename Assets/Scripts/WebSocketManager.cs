using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using BestHTTP.WebSocket;

public class WebSocketManager : MonoBehaviour
{
	string address = "";
	WebSocket webSocket;

	public void Init()
	{
		if (webSocket == null)
		{
			webSocket = new WebSocket(new Uri(address));

#if !UNITY_WEBGL
			webSocket.StartPingThread = true;
#endif
			//Subscribe to the WS events
			webSocket.OnOpen += OnOpen;
			webSocket.OnMessage += OnMessageReceived;
			webSocket.OnBinary += OnBinaryReceived;
			webSocket.OnClosed += OnClosed;
			webSocket.OnError += OnError;

			//Start connecting to the server
			webSocket.Open();
		}
	}

	public void Destory()
	{
		if (webSocket != null)
		{
			webSocket.Close();
			webSocket = null;
		}
	}

	void OnOpen(WebSocket ws)
	{
		Debug.Log("OnOpen: ");
		webSocket.Send("123");
	}

	void OnMessageReceived(WebSocket ws, string message)
	{
		Debug.LogFormat("OnMessageReceived: msg ={0}", message);
	}

	void OnBinaryReceived(WebSocket ws, byte[] data)
	{
		Debug.LogFormat("OnBinaryReceived: len ={0}", data.Length);
	}

	void OnClosed(WebSocket ws, UInt16 code, string message)
	{
		Debug.LogFormat("OnClosed: code ={0}, msg={1}", code, message);
		webSocket = null;
	}

	void OnError(WebSocket ws, string message)
	{
		string errorMsg = string.Empty;

#if !UNITY_WEBGL || UNITY_EDITOR
		if (ws.InternalRequest.Response != null)
		{
			errorMsg = string.Format("Status Code from Sever: {0} and Message: {1}",
				ws.InternalRequest.Response.StatusCode,
				ws.InternalRequest.Response.Message);
		}
#endif
		Debug.LogFormat("OnError: error occured: {0}\n", (message != null ? message : "Unknown Error" + errorMsg));
		webSocket = null;
	}
}
