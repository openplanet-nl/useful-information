void CopyableItem(const string &in name, const string &in value, bool showValue = true)
{
	string itemText = Icons::Clipboard + " " + name;
	if (showValue) {
		itemText += "\\$999 (" + ColoredString(value) + ")";
	}

	if (UI::MenuItem(itemText)) {
		IO::SetClipboard(value);
	}
}

void CopyableItem(const string &in name, int value, bool showValue = true) { CopyableItem(name, "" + value, showValue); }
void CopyableItem(const string &in name, uint value, bool showValue = true) { CopyableItem(name, "" + value, showValue); }
void CopyableItem(const string &in name, float value, bool showValue = true) { CopyableItem(name, "" + value, showValue); }

void RenderMenu()
{
	if (!UI::BeginMenu("\\$9cf" + Icons::InfoCircle + "\\$z Useful information")) {
		return;
	}

	auto app = cast<CTrackMania>(GetApp());
	auto network = cast<CTrackManiaNetwork>(app.Network);
	auto client = network.Client;

	auto serverInfo = cast<CGameCtnNetServerInfo>(network.ServerInfo);
	auto userInfo = cast<CTrackManiaPlayerInfo>(network.PlayerInfo);

	if (userInfo !is null && UI::BeginMenu(Icons::User + " Local user")) {
		CopyableItem("Name", userInfo.Name);
		CopyableItem("Login", userInfo.Login);
		CopyableItem("Webservices ID", userInfo.WebServicesUserId);
		UI::EndMenu();
	}

	if (app.RootMap !is null && UI::BeginMenu(Icons::Map + " Current map")) {
		auto mapInfo = app.RootMap.MapInfo;
		CopyableItem("Name", mapInfo.Name);
		CopyableItem("UID", mapInfo.MapUid);
		CopyableItem("Filename", mapInfo.FileName);
		CopyableItem("Coppers", mapInfo.CopperString);
		UI::Separator();
		CopyableItem("Author", mapInfo.AuthorNickName);
		CopyableItem("Author Login", mapInfo.AuthorLogin);
		UI::Separator();
		CopyableItem("Author Time", Time::Format(mapInfo.TMObjective_AuthorTime));
		CopyableItem("Gold Time", Time::Format(mapInfo.TMObjective_GoldTime));
		CopyableItem("Silver Time", Time::Format(mapInfo.TMObjective_SilverTime));
		CopyableItem("Bronze Time", Time::Format(mapInfo.TMObjective_BronzeTime));
		UI::EndMenu();
	}

	if (serverInfo !is null && serverInfo.ServerLogin != "" && UI::BeginMenu(Icons::Server + " Current server")) {
		CopyableItem("Name", serverInfo.ServerName);
		CopyableItem("Login", serverInfo.ServerLogin);
		CopyableItem("Joinlink", serverInfo.JoinLink);
		CopyableItem("Version", serverInfo.ServerVersionBuild);

		if (client.Connections.Length > 0) {
			auto connection = client.Connections[0];
			if (connection.ClientToServer) {
				auto connectionInfo = cast<CNetServerInfo>(connection.Info);
				UI::Separator();
				CopyableItem("IP", connectionInfo.RemoteIP);
				CopyableItem("UDP Port", connectionInfo.RemoteUDPPort);
				CopyableItem("TCP Port", connectionInfo.RemoteTCPPort);
			}
		}

		UI::Separator();
		if (UI::BeginMenu(Icons::Users + " Players")) {
			for (uint i = 0; i < network.PlayerInfos.Length; i++) {
				auto playerInfo = cast<CTrackManiaPlayerInfo>(network.PlayerInfos[i]);
				if (playerInfo is null || playerInfo is userInfo || playerInfo.Login == serverInfo.ServerLogin) {
					continue;
				}
				if (UI::BeginMenu(Icons::User + " " + ColoredString(playerInfo.Name))) {
					CopyableItem("Name", playerInfo.Name);
					CopyableItem("Login", playerInfo.Login);
					CopyableItem("Webservices ID", playerInfo.WebServicesUserId);
					UI::Separator();
					CopyableItem("Language", playerInfo.Language);
					CopyableItem("Trigram", playerInfo.Trigram);
					if (playerInfo.ClubTag != "") {
						CopyableItem("Clubtag", playerInfo.ClubTag);
					}
					UI::EndMenu();
				}
			}
			UI::EndMenu();
		}
		UI::EndMenu();
	}

	UI::EndMenu();
}
