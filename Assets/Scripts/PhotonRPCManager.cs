using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

public class PhotonRPCManager : MonoBehaviourPunCallbacks
{
	// Start is called before the first frame update
	void Start()
	{

	}

	// Update is called once per frame
	void Update()
	{

	}

	private void ConnectToPhoton(string nickName)
	{

	}

	public override void OnConnectedToMaster()
	{
		Debug.Log("你已經連線到PhotonMaster");
		if (!PhotonNetwork.InLobby)
		{
			PhotonNetwork.JoinLobby();
		}
	}

	public override void OnDisconnected(DisconnectCause cause)
	{
		base.OnDisconnected(cause);
	}

	public override void OnCreatedRoom()
	{
		base.OnCreatedRoom();
	}


}
