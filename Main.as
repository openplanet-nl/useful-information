void CopyableItem(const string &in name, const string &in value, bool showValue = true)
{
	string itemText = Icons::Clipboard + " " + name;
	if (showValue) {
		itemText += "\\$999 (" + Text::OpenplanetFormatCodes(value) + ")";
	}

	if (UI::MenuItem(itemText)) {
		IO::SetClipboard(value);
	}
}

void CopyableItem(const string &in name, int value, bool showValue = true) { CopyableItem(name, "" + value, showValue); }
void CopyableItem(const string &in name, uint value, bool showValue = true) { CopyableItem(name, "" + value, showValue); }
void CopyableItem(const string &in name, float value, bool showValue = true) { CopyableItem(name, "" + value, showValue); }

enum ListType
{
	Simple,
	Advanced,
}

string PluginsList(Meta::Plugin@[]@ plugins, ListType listType)
{
	string pluginList = "";
	for (uint i = 0; i < plugins.Length; i++) {
		auto plugin = plugins[i];
		if (listType == ListType::Simple)  {
			pluginList += SimplePluginInfo(plugin);
		} else if (listType == ListType::Advanced) {
			pluginList += AdvancedPluginInfo(plugin);
		}
	}

	return pluginList;
}

string SimplePluginInfo(Meta::Plugin@ plugin)
{
	string enabledText = plugin.Enabled ? "Enabled" : "Disabled";
	return plugin.Name + " | " + plugin.Version + " | " + enabledText + "\n";
}

string AdvancedPluginInfo(Meta::Plugin@ plugin)
{
	string output = plugin.ID + "\n";
	output += "  name: " + plugin.Name + "\n";
	output += "  version: " + plugin.Version + "\n";
	output += "  type: " + tostring(plugin.Type) + "\n";
	output += "  author: " + plugin.Author + "\n";
	output += "  category: " + plugin.Category + "\n";
	output += "  siteId: " + tostring(plugin.SiteID) + "\n";
	output += "  isEnabled: " + tostring(plugin.Enabled) + "\n";
	return output;
}


void RenderMenu()
{
	if (!UI::BeginMenu("\\$9cf" + Icons::InfoCircle + "\\$z Useful information")) {
		return;
	}

	auto app = cast<CTrackMania>(GetApp());
	auto network = cast<CTrackManiaNetwork>(app.Network);
	auto client = network.Client;
	auto plugins = Meta::AllPlugins();

	auto serverInfo = cast<CGameCtnNetServerInfo>(network.ServerInfo);
	auto userInfo = cast<CTrackManiaPlayerInfo>(network.PlayerInfo);

	if (plugins !is null && UI::BeginMenu(Icons::Tasks + " Plugins")) {
		if (UI::MenuItem(Icons::Clipboard + " Simple List")) {
			IO::SetClipboard(PluginsList(plugins, ListType::Simple));
		}
		if (UI::MenuItem(Icons::Clipboard + " Advanced List")) {
			IO::SetClipboard(PluginsList(plugins, ListType::Advanced));
		}
		UI::EndMenu();
	}

	if (userInfo !is null && UI::BeginMenu(Icons::User + " Local user")) {
		CopyableItem("Name", userInfo.Name);
		CopyableItem("Login", userInfo.Login);
#if TMNEXT
		CopyableItem("Webservices ID", userInfo.WebServicesUserId);
#endif
		UI::EndMenu();
	}

#if FOREVER
	if (app.Challenge !is null && UI::BeginMenu(Icons::Map + " Current map")) {
		auto map = app.Challenge;
		CopyableItem("Name", map.ChallengeName);
		CopyableItem("UID", map.Name);
		auto fid = GetFidFromNod(map);
		if (fid !is null) {
			CopyableItem("Filename", fid.FileName);
		}
		CopyableItem("Coppers", map.CopperPrice);
		UI::Separator();
		CopyableItem("Author", map.Author);
		UI::Separator();
		CopyableItem("Author Time", Time::Format(map.ChallengeParameters.AuthorTime));
		CopyableItem("Gold Time", Time::Format(map.ChallengeParameters.GoldTime));
		CopyableItem("Silver Time", Time::Format(map.ChallengeParameters.SilverTime));
		CopyableItem("Bronze Time", Time::Format(map.ChallengeParameters.BronzeTime));
		UI::EndMenu();
	}
#else
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
#endif

#if FOREVER
	string serverLogin = serverInfo.ServerHostName;
#else
	string serverLogin = serverInfo.ServerLogin;
#endif

	if (serverInfo !is null && serverLogin != "" && UI::BeginMenu(Icons::Server + " Current server")) {
		CopyableItem("Name", serverInfo.ServerName);
#if FOREVER
		CopyableItem("Hostname", serverLogin);
#else
		CopyableItem("Login", serverLogin);
		CopyableItem("Joinlink", serverInfo.JoinLink);
		CopyableItem("Version", serverInfo.ServerVersionBuild);
#endif

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
				if (playerInfo is null || playerInfo is userInfo || playerInfo.Login == serverLogin) {
					continue;
				}
				if (UI::BeginMenu(Icons::User + " " + Text::OpenplanetFormatCodes(playerInfo.Name))) {
					CopyableItem("Name", playerInfo.Name);
					CopyableItem("Login", playerInfo.Login);
#if TMNEXT
					CopyableItem("Webservices ID", playerInfo.WebServicesUserId);
#endif
					UI::Separator();
					CopyableItem("Language", playerInfo.Language);
#if TMNEXT
					CopyableItem("Trigram", playerInfo.Trigram);
					if (playerInfo.ClubTag != "") {
						CopyableItem("Clubtag", playerInfo.ClubTag);
					}
#endif
					UI::EndMenu();
				}
			}
			UI::EndMenu();
		}
		UI::EndMenu();
	}

	UI::EndMenu();
}
