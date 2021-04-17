library ieee;                                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_unsigned.all;                            -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_misc.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_MISC'

entity SERIAL_CBUS_SUM_DE0_NANO is                              -- deklaracja sprzegu 'SERIAL_CBUS_SUM_DE0_NANO'
  generic (
    L_ADRESOW		:natural := 2;				-- liczba slow przypadajacych na adres
    L_DANYCH		:natural := 4;				-- liczba slow przypadajacych na dana
    L_TAKTOW_ADRESU	:natural := 0;				-- liczba taktow stabilizacji adresu (i danej)
    L_TAKTOW_STROBU	:natural := 1;				-- liczba taktow trwania strobu
    L_TAKTOW_DANEJ	:natural := 0;				-- liczba taktow stabilizacji odbieranych danych
    F_ZEGARA            :natural := 20_000_000;                 -- czestotliwosc zegata w [Hz]
    L_MIN_BODOW         :natural := 110;                        -- minimalna predkosc nadawania w [bodach]
    B_SLOWA             :natural := 8;                          -- liczba bitow slowa danych (5-8)
    B_PARZYSTOSCI       :natural := 0;                          -- liczba bitow parzystosci (0-1)
    B_STOPOW            :natural := 1;                          -- liczba bitow stopu (1-2)
    N_SERIAL            :boolean := TRUE;                       -- negacja logiczna sygnalu szeregowego
    N_SLOWO             :boolean := TRUE                        -- negacja logiczna slowa danych
  );
  port(
    DE0_CLK             :in  std_logic;                         -- odbierany zegar systemowy 50 MHz z plyty DE0
    DE0_KEY             :in  std_logic_vector(1 downto 0);      -- odbierany stan przyciskow z plyty DE0
    DE0_SW              :in  std_logic_vector(3 downto 0);      -- odbierany stan przelacznikow z plyty DE0
    DE0_LED             :out std_logic_vector(7 downto 0);      -- sterowanie diodami LED na plytcie DE0
    DE0_TXD             :in  std_logic;                         -- odbierane dane szeregowe z plyty DE0
    DE0_RXD             :out std_logic;                         -- wysylane dane szeregowy do plyty DE0
    DE0_RTS             :in  std_logic;                         -- odbierana kontrola szeregowa z plyty DE0
    DE0_CTS             :out std_logic                          -- wysylana kontrola szeregowy do plyty DE0
  );
end entity SERIAL_CBUS_SUM_DE0_NANO;                            -- zakonczenie deklaracji sprzegu

architecture cialo of SERIAL_CBUS_SUM_DE0_NANO is	        -- deklaracja architektury 'cialo' dla sprzegu 'SERIAL_CBUS_SUM_DE0_NANO'

  signal RES             :std_logic;                            -- sygnal resetujacacy
  signal CLK             :std_logic;                            -- systemowy zegar taktujacy
  signal TX, RX          :std_logic;                            -- odbierany sygnal szeregowy

  signal SYNCH_GOTOWA	 :std_logic;				-- flaga potwierdzenia uzyskania synchronizacji
  signal BLAD_ODBIORU	 :std_logic;				-- flaga bledu odbioru

begin						                -- poczatek czesci wykonawczej architektury

  de0_inst: entity work.SERIAL_DE0_NANO				-- instancja projetu 'SERIAL_DE0_NANO'
    port map(							-- mapowanie portow
      DE0_CLK     	=> DE0_CLK,
      DE0_KEY     	=> DE0_KEY,
      DE0_SW      	=> DE0_SW,
      DE0_LED     	=> DE0_LED,
      DE0_TXD     	=> DE0_TXD,
      DE0_RXD     	=> DE0_RXD,
      DE0_RTS     	=> DE0_RTS,
      DE0_CTS     	=> DE0_CTS,
      CLK               => CLK,
      RES               => RES,
      BUT               => open,
      SW                => open,
      LED               => "00"&SYNCH_GOTOWA&BLAD_ODBIORU,
      TXD               => TX,
      RXD               => RX
    );

  serial_cbus_sum_inst: entity work.SERIAL_CBUS_SUM(behavioural)
    generic map (
      L_ADRESOW       => L_ADRESOW,
      L_DANYCH        => L_DANYCH,
      L_TAKTOW_ADRESU => L_TAKTOW_ADRESU,
      L_TAKTOW_STROBU => L_TAKTOW_STROBU,
      L_TAKTOW_DANEJ  => L_TAKTOW_DANEJ,
      F_ZEGARA        => F_ZEGARA,
      L_MIN_BODOW     => L_MIN_BODOW,
      B_SLOWA         => B_SLOWA,
      B_PARZYSTOSCI   => B_PARZYSTOSCI,
      B_STOPOW        => B_STOPOW,
      N_SERIAL        => N_SERIAL,
      N_SLOWO         => N_SLOWO
    )                     
    port map (            
      R               => RES, 
      C               => CLK, 
      RX              => TX ,
      TX              => RX ,
      SYNCH_GOTOWA    => SYNCH_GOTOWA,
      BLAD_ODBIORU    => BLAD_ODBIORU
   );

 end architecture cialo;                                 	-- zakonczenie architektury 'cialo'
