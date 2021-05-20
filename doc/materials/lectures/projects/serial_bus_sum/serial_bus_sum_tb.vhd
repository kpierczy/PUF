library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;

library work;
use     work.serial_lib.all;
use     work.serial_lib_tb.all;

entity SERIAL_BUS_SUM_TB is
  generic (
    L_ADRESOW		:natural := 1;				-- liczba slow przypadajacych na adres
    L_DANYCH		:natural := 1;				-- liczba slow przypadajacych na dana
    L_TAKTOW_ADRESU	:natural := 0;				-- liczba taktow stabilizacji adresu (i danej)
    L_TAKTOW_STROBU	:natural := 1;				-- liczba taktow trwania strobu
    L_TAKTOW_DANEJ	:natural := 0;				-- liczba taktow stabilizacji odbieranych danych
    F_ZEGARA		:natural := 20000000;			-- czestotliwosc zegata w [Hz]
    L_MIN_BODOW		:natural := 110;			-- minimalna predkosc nadawania w [bodach]
    B_SLOWA		:natural := 8;				-- liczba bitow slowa danych (5-8)
    B_PARZYSTOSCI	:natural := 1;				-- liczba bitow parzystosci (0-1)
    B_STOPOW		:natural := 2;				-- liczba bitow stopu (1-2)
    N_SERIAL		:boolean := FALSE;			-- negacja logiczna sygnalu szeregowego
    N_SLOWO		:boolean := FALSE			-- negacja logiczna slowa danych
  );
end SERIAL_BUS_SUM_TB;

architecture behavioural of SERIAL_BUS_SUM_TB is

  constant L_BODOW	:natural := 2000000;			-- predkosc nadawania w [bodach]
  constant L_TESTOW	:natural := 4;				-- liczba wyslanych slow testowych
  signal   R		:std_logic;				-- sygnal resetowania
  signal   C		:std_logic;				-- zegar taktujacy
  signal   RX		:std_logic;				-- odbierany sygnal szeregowy
  signal   TX		:std_logic;				-- wysylany sygnal szeregowy
  signal   SYNCH_GOTOWA	:std_logic;				-- sygnal potwierdzenia synchronizacji
  signal   BLAD_ODBIORU	:std_logic;				-- sygnal bledu odbioru

  constant O_ZEGARA	:time := 1 sec/F_ZEGARA;

  signal   DANA_ODCZ    :std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0);

begin

  TB_zegar(O_ZEGARA,C);
  TB_reset(100ns,R);
  
  process is
    variable ADRES      :std_logic_vector(L_ADRESOW*B_SLOWA-1 downto 0);
    variable DANA_WY    :std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0);
    variable DANA_WE    :std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0);
    variable KONFIG	:TB_serial_bus_konfig;
    variable BLAD	:boolean;
    
  begin

    TB_serial_bus_inicjal(L_ADRESOW, L_DANYCH, L_BODOW, B_SLOWA, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, KONFIG, RX, BLAD);
    if (BLAD=TRUE) then wait; end if;

    wait until R='0';
    wait for 100ns;

    TB_serial_bus_synch(L_TESTOW, KONFIG, RX, TX, BLAD);
    if (BLAD=TRUE) then wait; end if;

    ADRES   := (ADRES'range=>'0')+5;
    DANA_WY := (DANA_WY'range=>'0')+123;
    TB_serial_bus_zapis(KONFIG, ADRES, DANA_WY, RX, TX, BLAD);
    if (BLAD=TRUE) then wait; end if;
    TB_serial_bus_odczyt(KONFIG, ADRES, DANA_WE, RX, TX, BLAD);
    if (BLAD=TRUE) then wait; end if;
    if (DANA_WY /= DANA_WE) then BLAD := TRUE; wait; end if;
    DANA_ODCZ <= DANA_WE;
    wait for 0ns;
 
    ADRES   := (ADRES'range=>'0')+23;
    DANA_WY := (DANA_WY'range=>'0')+37;
    TB_serial_bus_zapis(KONFIG, ADRES, DANA_WY, RX, TX, BLAD);
    if (BLAD=TRUE) then wait; end if;
    TB_serial_bus_odczyt(KONFIG, ADRES, DANA_WE, RX, TX, BLAD);
    if (BLAD=TRUE) then wait; end if;
    if (DANA_WY /= DANA_WE) then BLAD := TRUE; wait; end if;
    DANA_ODCZ <= DANA_WE;
    wait for 0ns;

 
    ADRES := (ADRES'range=>'0')+124;
    TB_serial_bus_odczyt(KONFIG, ADRES, DANA_WE, RX, TX, BLAD);
    if (BLAD=TRUE) then wait; end if;
    DANA_ODCZ <= DANA_WE;
    wait for 0ns;

    wait;
  end process;
  
  serial_bus_sum_inst: entity work.SERIAL_BUS_SUM(behavioural)
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
      R               => R, 
      C               => C, 
      RX              => RX ,
      TX              => TX ,
      SYNCH_GOTOWA    => SYNCH_GOTOWA,
      BLAD_ODBIORU    => BLAD_ODBIORU
   );
end behavioural;

