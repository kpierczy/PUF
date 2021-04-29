library ieee;                                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_unsigned.all;                            -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_misc.all;                                -- dolaczenie calego pakietu 'STD_LOGIC_MISC'

entity SERIAL_INTERF_DE0_NANO is                                -- deklaracja sprzegu 'SERIAL_INTERF_DE0_NANO'
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
    DE0_CLK             :in  std_logic;                         -- odbierany zegar systemowy 50 MHz z plyty DE0
    DE0_KEY             :in  std_logic_vector(1 downto 0);      -- odbierany stan przyciskow z plyty DE0
    DE0_SW              :in  std_logic_vector(3 downto 0);      -- odbierany stan przelacznikow z plyty DE0
    DE0_LED             :out std_logic_vector(7 downto 0);      -- sterowanie diodami LED na plytcie DE0
    DE0_TXD             :in  std_logic;                         -- odbierane dane szeregowe z plyty DE0
    DE0_RXD             :out std_logic;                         -- wysylane dane szeregowy do plyty DE0
    DE0_RTS             :in  std_logic;                         -- odbierana kontrola szeregowa z plyty DE0
    DE0_CTS             :out std_logic                          -- wysylana kontrola szeregowy do plyty DE0
  );
end entity SERIAL_INTERF_DE0_NANO;                              -- zakonczenie deklaracji sprzegu

architecture cialo of SERIAL_INTERF_DE0_NANO is	                -- deklaracja architektury 'cialo' dla sprzegu 'SERIAL_INTERF_DE0_NANO'

  signal RES             :std_logic;                            -- sygnal resetujacacy
  signal CLK             :std_logic;                            -- systemowy zegar taktujacy
  signal TX, RX          :std_logic;                            -- odbierany sygnal szeregowy

  signal srx_slowo	 :std_logic_vector(B_SLOWA-1 downto 0);	-- odebrane slowo danych
  signal srx_gotowe	 :std_logic;				-- flaga potwierdzenia odbioru
  signal srx_blad	 :std_logic;				-- flaga wykrycia bledu w odbiorze

  signal stx_slowo	 :std_logic_vector(B_SLOWA-1 downto 0);	-- wysylane slowo danych

  signal interf_sync	 :std_logic;				-- flaga potwierdzenia uzyskania synchronizacji

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
      LED               => '0'&interf_sync&srx_blad&srx_gotowe,
      TXD               => TX,
      RXD               => RX
    );

  stx_slowo <= srx_slowo+1;
  serial_interf_inst: entity work.SERIAL_INTERF(behavioural)
    generic map (
      F_ZEGARA        => F_ZEGARA,
      L_MIN_BODOW     => L_MIN_BODOW,
      B_SLOWA         => B_SLOWA,
      B_PARZYSTOSCI   => B_PARZYSTOSCI,
      B_STOPOW        => B_STOPOW,
      N_SERIAL	      => N_SERIAL,
      N_SLOWO         => N_SLOWO
    )
    port map (
      R               => RES,
      C               => CLK,
      RX              => TX,
      TX              => RX,
      RX_ODEBRANE     => srx_gotowe,
      RX_SLOWO        => srx_slowo,
      TX_WOLNY        => open,
      TX_NADAJ        => srx_gotowe,
      TX_SLOWO        => stx_slowo,
      SYNCH_GOTOWA    => interf_sync,
      BLAD_ODBIORU    => srx_blad
   );
end architecture cialo;                                 	-- zakonczenie architektury 'cialo'
