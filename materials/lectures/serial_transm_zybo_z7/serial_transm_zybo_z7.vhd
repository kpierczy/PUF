library ieee;                                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_unsigned.all;                            -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_misc.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_MISC'

entity SERIAL_TRANSM_ZYBO_Z7 is                                 -- deklaracja sprzegu 'SERIAL_ZYBO_Z7_TEST'
  generic (
    F_ZEGARA            :natural := 20_000_000;                 -- czestotliwosc zegata w [Hz]
    L_MIN_BODOW         :natural := 110;                        -- minimalna predkosc nadawania w [bodach]
    B_SLOWA             :natural := 8;                          -- liczba bitow slowa danych (5-8)
    B_PARZYSTOSCI       :natural := 0;                          -- liczba bitow parzystosci (0-1)
    B_STOPOW            :natural := 1;                          -- liczba bitow stopu (1-2)
    N_SERIAL            :boolean := TRUE;                       -- negacja logiczna sygnalu szeregowego
    N_SLOWO             :boolean := TRUE                        -- negacja logiczna slowa danych
  );
  port(
    SYSCLK              :in  std_logic;                         -- systemowy zegar taktujacy na plycie
    BTN                 :in  std_logic_vector(0 to 3);          -- odczyt stanow pryciskow na plycie
    LED                 :out std_logic_vector(0 to 3);          -- sterowanie diodami del na plycie
    LED_R, LED_G, LED_B :out std_logic;                         -- sterowanie dioda rgb na plycie
    TXD			:in  std_logic;				-- odbierany sygnal szeregowy na plycie
    RXD                 :out std_logic;                         -- wysylany sygnal szeregowy na plycie
    RTS                 :in  std_logic;                         -- odbierany sygnal szeregowy na plycie
    CTS                 :out std_logic                          -- wysylany sygnal szeregowy na plycie
  );
end entity SERIAL_TRANSM_ZYBO_Z7;                               -- zakonczenie deklaracji sprzegu

architecture cialo of SERIAL_TRANSM_ZYBO_Z7 is	                -- deklaracja architektury 'cialo' dla sprzegu 'SERIAL_ZYBO_Z7_TEST'

  signal RES             :std_logic;                            -- sygnal resetujacacy
  signal CLK             :std_logic;                            -- systemowy zegar taktujacy
  signal TX, RX          :std_logic;                            -- odbierany sygnal szeregowy
  signal BT1, BT2, BT3   :std_logic;                            -- stan zatrzymania

  signal   srx_slowo	 :std_logic_vector(B_SLOWA-1 downto 0);	-- odebrane slowo danych
  signal   srx_gotowe	 :std_logic;				-- flaga potwierdzenia odbioru
  signal   srx_blad	 :std_logic;				-- flaga wykrycia bledu w odbiorze

  signal   stx_slowo	 :std_logic_vector(B_SLOWA-1 downto 0);	-- wysylane slowo danych
  signal   stx_zajety	 :std_logic;				-- flaga potwierdzenia nadawania

begin						                -- poczatek czesci wykonawczej architektury

  zybo_inst: entity work.SERIAL_ZYBO_Z7				-- instancja projetu 'SERIAL_ZYBO_Z7'
    port map(							-- mapowanie portow
      SYSCLK            => SYSCLK,
      BTN               => BTN,
      LED               => LED,
      LED_R             => LED_R,
      LED_G             => LED_G,
      LED_B             => LED_B,
      TXD               => TXD,
      RXD               => RXD,
      RTS               => RTS,
      CTS               => CTS,
      CLK               => CLK,
      RES               => RES,
      BT1               => BT1,
      BT2               => BT2,
      BT3               => BT3,
      LD0               => RES,
      LD1               => srx_blad,
      LD2               => srx_gotowe,
      LD3               => stx_zajety,
      TX                => TX,
      RX                => RX
    );

  srx: entity work.SERIAL_RX(behavioural)			-- instancja odbiornika szeregowego 'SERIAL_SYNCH_RX'
    generic map(						-- mapowanie parametrow biezacych
      F_ZEGARA             => F_ZEGARA,				-- czestotliwosc zegata w [Hz]
      L_MIN_BODOW          => L_MIN_BODOW,			-- predkosc minimlana nadawania w [bodach]
      B_SLOWA              => B_SLOWA,				-- liczba bitow slowa danych (5-8)
      B_PARZYSTOSCI        => B_PARZYSTOSCI,			-- liczba bitow parzystosci (0-1)
      B_STOPOW             => B_STOPOW,				-- liczba bitow stopu (1-2)
      N_RX                 => N_SERIAL,				-- negacja logiczna sygnalu szeregowego
      N_SLOWO              => N_SLOWO				-- negacja logiczna slowa danych
    )
    port map(							-- mapowanie sygnalow do portow
      R                    => RES,				-- sygnal resetowania
      C                    => CLK,				-- zegar taktujacy
      T_BODU               => F_ZEGARA/9600,				-- liczba taktow zegara dla jednego bodu
      RX                   => TX,				-- odebrany sygnal szeregowy
      SLOWO                => srx_slowo,			-- odebrane slowo danych
      GOTOWE               => srx_gotowe,			-- flaga potwierdzenia odbioru
      BLAD                 => srx_blad				-- flaga wykrycia bledu w odbiorze
    );

  stx_slowo <= srx_slowo + 1;
  stx: entity work.SERIAL_TX(behavioural)			-- instancja nadajnika szeregowego 'SERIAL_TX'
    generic map(						-- mapowanie parametrow biezacych
      F_ZEGARA             => F_ZEGARA,				-- czestotliwosc zegata w [Hz]
      L_MIN_BODOW          => L_MIN_BODOW,			-- predkosc minimlana nadawania w [bodach]
      B_SLOWA              => B_SLOWA,				-- liczba bitow slowa danych (5-8)
      B_PARZYSTOSCI        => B_PARZYSTOSCI,			-- liczba bitow parzystosci (0-1)
      B_STOPOW             => B_STOPOW,				-- liczba bitow stopu (1-2)
      N_TX                 => N_SERIAL,				-- negacja logiczna sygnalu szeregowego
      N_SLOWO              => N_SLOWO				-- negacja logiczna slowa danych
    )
    port map(							-- mapowanie sygnalow do portow
      R                    => RES,				-- sygnal resetowania
      C                    => CLK,				-- zegar taktujacy
      T_BODU               => F_ZEGARA/9600,				-- liczba taktow zegara dla jednego bodu
      TX                   => RX,				-- nadawany sygnal szeregowy
      SLOWO                => stx_slowo,			-- nadawane slowo danych
      NADAJ                => srx_gotowe,			-- flaga zadania nadawania
      WYSYLANIE            => stx_zajety			-- flaga potwierdzenia nadawania
    );

end architecture cialo;                                 	-- zakonczenie architektury 'cialo'
