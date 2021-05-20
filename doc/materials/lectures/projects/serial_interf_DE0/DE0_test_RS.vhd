library ieee;                                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_unsigned.all;                            -- dolaczenie calego pakietu 'STD_LOGIC_UNSIGNED'

entity DE0_TEST_RS is                                   	-- deklaracja sprzegu 'DE0_TEST_RS'
  generic (
    F_ZEGARA		:natural := 50_000_000;			-- czestotliwosc zegata w [Hz]
    L_MIN_BODOW		:natural := 110;			-- minimalna predkosc nadawania w [bodach]
    B_SLOWA		:natural := 8;				-- liczba bitow slowa danych (5-8)
    B_PARZYSTOSCI	:natural := 0;				-- liczba bitow parzystosci (0-1)
    B_STOPOW		:natural := 1;				-- liczba bitow stopu (1-2)
    N_SERIAL		:boolean := TRUE;			-- negacja logiczna sygnalu szeregowego
    N_SLOWO		:boolean := TRUE			-- negacja logiczna slowa danych
  );
  port(
    CLK			:in  std_logic;                         -- odbierany zegar systemowy 50 MHz z plyty DE0
    KEY			:in  std_logic_vector(1 downto 0);      -- odbierany stan przyciskow z plyty DE0
    SW			:in  std_logic_vector(3 downto 0);      -- odbierany stan przelacznikow z plyty DE0
    LED			:out std_logic_vector(7 downto 0);      -- sterowanie diodami LED na plycie DE0
    TXD			:in  std_logic;                         -- odbierane dane szeregowe z plytki CP2102
    RXD			:out std_logic;                         -- wysylane dane szeregowy do plytki CP2102
    RTS			:in  std_logic;                         -- odbierana kontrola szeregowa z plytki CP2102
    CTS			:out std_logic                          -- wysylana kontrola szeregowy do plytki CP2102
  );
end entity DE0_TEST_RS;                                 	-- zakonczenie deklaracji sprzegu

architecture cialo of DE0_TEST_RS is	                	-- deklaracja architektury 'cialo' dla sprzegu 'DE0_TEST_RS'

  signal   RX_ODEBRANE	:std_logic;				-- flaga potwierdzenia odbioru
  signal   RX_SLOWO	:std_logic_vector(B_SLOWA-1 downto 0);	-- odebrane slowo danych
  signal   TX_SLOWO	:std_logic_vector(B_SLOWA-1 downto 0);	-- wysylane slowo danych

begin						                -- poczatek czesci wykonawczej architektury

  SERIAL_INTERF_INST: entity work.SERIAL_INTERF			-- instancja odbirnika szeregowego 'SERIAL_INTERF'
    generic map(						-- mapowanie parametrow biezacych
      F_ZEGARA             => F_ZEGARA,				-- czestotliwosc zegata w [Hz]
      L_MIN_BODOW          => L_MIN_BODOW,			-- predkosc odbierania w [bodach]
      B_SLOWA              => B_SLOWA,				-- liczba bitow slowa danych (5-8)
      B_PARZYSTOSCI        => B_PARZYSTOSCI,			-- liczba bitow parzystosci (0-1)
      B_STOPOW             => B_STOPOW,				-- liczba bitow stopu (1-2)
      N_SERIAL             => TRUE,				-- negacja logiczna sygnalu szeregowego
      N_SLOWO              => TRUE				-- negacja logiczna slowa danych
    )
    port map(							-- mapowanie sygnalow do portow
      R                    => KEY(0),				-- sygnal resetowania
      C                    => CLK,				-- zegar taktujacy
      RX                   => TXD,				-- odebrany sygnal szeregowy
      TX                   => RXD,				-- nadawany sygnal szeregowy
      RX_ODEBRANE          => RX_ODEBRANE,			-- flaga potwierdzenia odbioru
      RX_SLOWO             => RX_SLOWO,				-- odebrane slowo danych
      TX_WOLNY             => open,				-- niepodlaczona flaga gotowosci do nadawania
      TX_NADAJ             => RX_ODEBRANE,			-- flaga zadania nadania
      TX_SLOWO             => TX_SLOWO,				-- wysylane slowo danych
      SYNCH_GOTOWA         => LED(0),				-- sygnal synchronizacji podlaczony do 'LED(0)'
      BLAD_ODBIORU         => LED(7)				-- sygnal bledu odbioru podlaczony do 'LED(7)'
   );
   
   TX_SLOWO <= RX_SLOWO+1;					-- przypisanie do 'TX_SLOWO' wartosci 'RX_SLOWO+1'

end architecture cialo;                                 	-- zakonczenie architektury 'cialo'
