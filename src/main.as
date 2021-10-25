ChatWindow g_window;

void Update(float dt)
{
	g_window.Update(dt);
}

void Render()
{
	g_window.Render();
	Renderables::Render();
}

bool OnKeyPress(bool down, VirtualKey key)
{
	return g_window.OnKeyPress(down, key);
}

void OnDisabled()
{
	g_window.SendChatFormat("text");
	ShowNadeoChat(true);
}

void OnDestroyed()
{
	g_window.SendChatFormat("text");
	ShowNadeoChat(true);
}

void OnSettingsChanged()
{
	Sounds::CheckIfSoundSetChanged();
}

void SendChatMessage(const string &in text)
{
#if TMNEXT
	if (!Permissions::InGameChat()) {
		return;
	}
#endif

	auto pg = GetApp().CurrentPlayground;
	if (pg is null) {
		//TODO: Queue the message for later
		warn("Can't send message right now because there's no playground!");
		return;
	}
	pg.Interface.ChatEntry = text;
}

void ShowNadeoChat(bool visible)
{
	auto ctlRoot = GameInterface::GetRoot();
	if (ctlRoot !is null) {
		auto ctlChat = cast<CControlContainer>(GameInterface::ControlFromID(ctlRoot, "FrameChat"));
		if (ctlChat !is null) {
#if MP41 || TURBO
			// On MP4, we can't simply hide FrameChat by setting IsHiddenExternal
			// Instead, we use a trick with IsClippingContainer and BoxMin
			ctlChat.IsClippingContainer = !visible;
			ctlChat.BoxMin = vec2();

			auto ctlChatInput = GameInterface::ControlFromID(ctlChat, "OverlayChatInput");
			if (ctlChatInput !is null) {
				ctlChatInput.IsHiddenExternal = !visible;
			}
#else
			ctlChat.IsHiddenExternal = !visible;
#endif
		}
	}
}

void Main()
{
	Sounds::Load();
	Emotes::Load();
	Commands::Load();

	g_window.Initialize();

	startnew(ChatMessageLoop, @g_window);

	while (true) {
#if DEVELOPER
		ShowNadeoChat(Setting_ShowNadeoChat);
#else
		ShowNadeoChat(false);
#endif

		if (g_window.m_requestedChatFormat != "json") {
			g_window.SendChatFormat("json");
		}

		yield();
	}
}
