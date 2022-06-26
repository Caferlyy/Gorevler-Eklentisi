#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Caferly!"
#define PLUGIN_VERSION "1.1"

#include <sourcemod>
#include <cstrike> 
#include <sdktools>
#include <clientprefs>

Handle g_gorevlerKillCookie;

ConVar g_EklentiTagi; //  * - *
ConVar g_IlkGorev;//  * - *
ConVar g_IkinciGorev;//  * - *
ConVar g_UcuncuGorev;//  * - *
ConVar g_DorduncuGorev;//  * - *
ConVar g_gorevlerMaxKill;//  * - *

public Plugin myinfo = 
{
    name = "Görevler Eklentisi",
    author = PLUGIN_AUTHOR,
    description = "Oyunculara görev verilerek bu görevleri yapınca ödül alması sağlanmaktadır",
    version = PLUGIN_VERSION,
    url = "https://hovn.com - #CAFERLY"
};

public void OnPluginStart()
{
    RegConsoleCmd("sm_gorevler", Gorev);
    RegConsoleCmd("sm_gorev", Gorev);
    HookEvent("player_death", Oluadamvar);
    g_gorevlerKillCookie = RegClientCookie("GorevlerKillCookie", "Kill aldıkça yükselen görev cookiesi", CookieAccess_Protected);
    g_gorevlerMaxKill = CreateConVar("caferly_max_kill", "25", "Oyunucu maximim kaç görev puanı saklayabilsin");
    g_EklentiTagi = CreateConVar("caferly_eklenti_tagi", "Caferly", "Bütün eklentilerin reklamlarını buradan değiştirebilirsiniz. ([ ] gibi işaretler koymayınız)");
    g_IlkGorev = CreateConVar("caferly_gorev1_gereken", "3", "İlk görevi tamamlamak için gereken kill sayısı");
    g_IkinciGorev = CreateConVar("caferly_gorev2_gereken", "5", "İkinci görevi tamamlamak için gereken kill sayısı");
    g_UcuncuGorev = CreateConVar("caferly_gorev3_gereken", "7", "Üçüncü görevi tamamlamak için gereken kill sayısı");
    g_DorduncuGorev = CreateConVar("caferly_gorev4_gereken", "10", "Dördüncü görevi tamamlamak için gereken kill sayısı");
}

public void OnMapStart()
{
    AutoExecConfig(true, "caferly_Gorevler");
    char mapismi[128];
    GetCurrentMap(mapismi, 128);
    char EklentiIsmi[128];
    GetPluginFilename(INVALID_HANDLE, EklentiIsmi, sizeof(EklentiIsmi));
    if (StrContains(mapismi, "jb_", false) && StrContains(mapismi, "jail_", false) && StrContains(mapismi, "ba_jail", false))
    {
        ServerCommand("sm plugins unload %s", EklentiIsmi);
    }
    else
    {
        PrintToServer("!-------Gorevler eklentisi basari ile calistirildi-------!");
    }

}

public void OnClientPutInServer(int client)
{
    /*char buffer[64];
    char test[64];
    int killsayisi = GetClientCookie(client, g_gorevlerKillCookie, buffer, sizeof(buffer));
    
    if(IntToString(killsayisi, test, sizeof(test)) > 0)
    {
        PrintToConsole(client, "Kaytili görevlerin yüklendi !");
    }
    else
    {
        SetClientCookie(client, g_gorevlerKillCookie, "0");
    }*/
    
    if(AreClientCookiesCached(client))
    {
        PrintToConsole(client, "Kaytili görev puanlarin yüklendi !");
    }
    else
    {
        SetClientCookie(client, g_gorevlerKillCookie, "0");
    }
}

public Action Gorev(int client, int args)
{
    char buffer[64];
    char gorev1[255];
    char gorev2[255];
    char gorev3[255];
    char gorev4[255];
    char IlkGorev[64];
    char IkinciGorev[64];
    char UcuncuGorev[64];
    char DorduncuGorev[64];
    char Eklenti_Tagi[64];
    GetConVarString(g_IlkGorev, IlkGorev, sizeof(IlkGorev));
    GetConVarString(g_IkinciGorev, IkinciGorev, sizeof(IkinciGorev));
    GetConVarString(g_UcuncuGorev, UcuncuGorev, sizeof(UcuncuGorev));
    GetConVarString(g_DorduncuGorev, DorduncuGorev, sizeof(DorduncuGorev));
    GetConVarString(g_EklentiTagi, Eklenti_Tagi, sizeof(Eklenti_Tagi));
    
    GetClientCookie(client, g_gorevlerKillCookie, buffer, sizeof(buffer));
    
    Format(gorev1, sizeof(gorev1), " %s Tane Ct Öldür Ödül: 1 Sağlık Aşısı", IlkGorev);
    Format(gorev2, sizeof(gorev2), " %s Tane Ct Öldür Ödül: El Bombası + Molotof", IkinciGorev);
    Format(gorev3, sizeof(gorev3), " %s Tane Ct Öldür Ödül: 1 Mermili Zeus", UcuncuGorev);
    Format(gorev4, sizeof(gorev4), " %s Tane Ct Öldür Ödül: 150 Can + 150 Armor", DorduncuGorev);
        
    Menu menu = new Menu(gorevmenu_Handler);
    menu.SetTitle("[%s] !> Görevler <!\n------------------------\nGörev Puanın: %s\n------------------------", Eklenti_Tagi, buffer);
    if(StringToInt(buffer, 10) >= StringToInt(IlkGorev, 10))
    {
        menu.AddItem("killGorev1", gorev1);
    }
    else
    {
        menu.AddItem("killGorev1", gorev1, ITEMDRAW_DISABLED);
    }
    if(StringToInt(buffer, 10) >= StringToInt(IkinciGorev, 10))
    {
        menu.AddItem("killGorev2", gorev2);
    }
    else
    {
        menu.AddItem("killGorev2", gorev2, ITEMDRAW_DISABLED);
    }
    if(StringToInt(buffer, 10) >= StringToInt(UcuncuGorev, 10))
    {
        menu.AddItem("killGorev3", gorev3);
    }
    else
    {
        menu.AddItem("killGorev3", gorev3, ITEMDRAW_DISABLED);
    }
    if(StringToInt(buffer, 10) >= StringToInt(DorduncuGorev, 10))
    {
        menu.AddItem("killGorev4", gorev4);
    }
    else
    {
        menu.AddItem("killGorev4", gorev4, ITEMDRAW_DISABLED);
    }
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int gorevmenu_Handler(Handle menu, MenuAction action, int client, int position)
{
    if( action == MenuAction_Select )
    {
        char Item[32];
        char cookie[64];
        char Eklenti_Tagi[32];
        GetClientCookie(client, g_gorevlerKillCookie, cookie, sizeof(cookie));
        GetMenuItem(menu, position, Item, sizeof(Item));
        GetConVarString(g_EklentiTagi, Eklenti_Tagi, sizeof(Eklenti_Tagi));
        
        if (StrEqual(Item, "killGorev1"))
        {
            char IlkGorev[64];
            GetConVarString(g_IlkGorev, IlkGorev, sizeof(IlkGorev));
            if(StringToInt(cookie, 10) >= StringToInt(IlkGorev, 10))
            {
                PrintToChat(client, " \x02[%s] \x0E%N \x01 tebrikler görevi başarıyla tamamladın !", Eklenti_Tagi, client);
                GivePlayerItem(client, "weapon_healthshot");
                char cikarma[64];
                int yeni = StringToInt(cookie, 10) - StringToInt(IlkGorev, 10);
                IntToString(yeni, cikarma, sizeof(cikarma));
                SetClientCookie(client, g_gorevlerKillCookie, cikarma);
            }
            else
            {
                PrintToChat(client, " \x02[%s] \x0E%N \x01 görevi henüz tamamlayamazsın !", Eklenti_Tagi, client);
            }
        }
        if (StrEqual(Item, "killGorev2"))
        {
            char IkinciGorev[64];
            GetConVarString(g_IkinciGorev, IkinciGorev, sizeof(IkinciGorev));
            if(StringToInt(cookie, 10) >= StringToInt(IkinciGorev, 10))
            {
                PrintToChat(client, " \x02[%s] \x0E%N \x01 tebrikler görevi başarıyla tamamladın !", Eklenti_Tagi, client);
                GivePlayerItem(client, "weapon_molotov");
                GivePlayerItem(client, "weapon_hegrenade");
                char cikarma[64];
                int yeni = StringToInt(cookie, 10) - StringToInt(IkinciGorev, 10);
                IntToString(yeni, cikarma, sizeof(cikarma));
                SetClientCookie(client, g_gorevlerKillCookie, cikarma);
            }
            else
            {
                PrintToChat(client, " \x02[%s] \x0E%N \x01 görevi henüz tamamlayamazsın !", Eklenti_Tagi, client);
            }
        }
        if (StrEqual(Item, "killGorev3"))
        {
            char UcuncuGorev[64];
            GetConVarString(g_UcuncuGorev, UcuncuGorev, sizeof(UcuncuGorev));
            if(StringToInt(cookie, 10) >= StringToInt(UcuncuGorev, 10))
            {
                PrintToChat(client, " \x02[%s] \x0E%N \x01 tebrikler görevi başarıyla tamamladın !", Eklenti_Tagi, client);
                char cikarma[64];
                int yeni = StringToInt(cookie, 10) - StringToInt(UcuncuGorev, 10);
                IntToString(yeni, cikarma, sizeof(cikarma));
                SetClientCookie(client, g_gorevlerKillCookie, cikarma);
                GivePlayerItem(client, "weapon_taser");            
            }
            else
            {
                PrintToChat(client, " \x02[%s] \x0E%N \x01 görevi henüz tamamlayamazsın !", Eklenti_Tagi, client);
            }
        }
        if (StrEqual(Item, "killGorev4"))
        {
            char DorduncuGorev[64];
            GetConVarString(g_DorduncuGorev, DorduncuGorev, sizeof(DorduncuGorev));
            if(StringToInt(cookie, 10) >= StringToInt(DorduncuGorev, 10))
            {
                PrintToChat(client, " \x02[%s] \x0E%N \x01 tebrikler görevi başarıyla tamamladın !", Eklenti_Tagi, client);
                char cikarma[64];
                int yeni = StringToInt(cookie, 10) - StringToInt(DorduncuGorev, 10);
                IntToString(yeni, cikarma, sizeof(cikarma));
                SetClientCookie(client, g_gorevlerKillCookie, cikarma);
                SetEntityHealth(client, 150);
                SetEntProp(client, Prop_Send, "m_ArmorValue", 150);
            }
            else
            {
                PrintToChat(client, " \x02[%s] \x0E%N \x01 görevi henüz tamamlayamazsın !", Eklenti_Tagi, client);
            }
        }
    }
    else if(action == MenuAction_End)
    {
        CloseHandle(menu);
    }
}

public Action Oluadamvar(Handle event, char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    
    char Eklenti_Tagi[64];
    GetConVarString(g_EklentiTagi, Eklenti_Tagi, sizeof(Eklenti_Tagi));
    if(GetClientTeam(client) == CS_TEAM_CT)
    {
        if(GetClientTeam(attacker) == CS_TEAM_T)
        {    
            char buffer[64];
            char ekleme[64];
            char Max[64];
            GetClientCookie(attacker, g_gorevlerKillCookie, buffer, sizeof(buffer));
            int yeni = StringToInt(buffer, 10) + 1;
            IntToString(yeni, ekleme, sizeof(ekleme));
            GetConVarString(g_gorevlerMaxKill, Max, sizeof(Max));
            if(StringToInt(buffer, 10) > StringToInt(Max, 10))
            {
                SetClientCookie(attacker, g_gorevlerKillCookie, ekleme);
                PrintToChat(attacker, " \x02[%s] \x0E%N \x01ct öldürdüğün için 1 görev puanı kazandın !", Eklenti_Tagi, attacker);
            }
            else
            {
                PrintToChat(attacker, " \x02[%s] \x0E%N \x01maksimium puana ulaştığın için puan kazanamadın !", Eklenti_Tagi, attacker);
            }
        }
    }
} 