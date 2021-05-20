library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;

library work;
use     work.serial_bus_lib.all;

entity SERIAL_BUS_TB is
  generic (
    L_ADRESOW		:natural := 2;				-- liczba slow przypadajacych na adres
    L_DANYCH		:natural := 4;				-- liczba slow przypadajacych na dana
    L_TAKTOW_ADRESU	:natural := 2;				-- liczba taktow stabilizacji adresu (i danej)
    L_TAKTOW_STROBU	:natural := 1;				-- liczba taktow trwania strobu
    L_TAKTOW_DANEJ	:natural := 3;				-- liczba taktow stabilizacji odbieranych danych
    F_ZEGARA		:natural := 20_000_000;			-- czestotliwosc zegata w [Hz]
    L_MIN_BODOW		:natural := 110;			-- minimalna predkosc nadawania w [bodach]
    B_SLOWA		:natural := 8;				-- liczba bitow slowa danych (5-8)
    B_PARZYSTOSCI	:natural := 1;				-- liczba bitow parzystosci (0-1)
    B_STOPOW		:natural := 2;				-- liczba bitow stopu (1-2)
    N_SERIAL		:boolean := FALSE;			-- negacja logiczna sygnalu szeregowego
    N_SLOWO		:boolean := FALSE			-- negacja logiczna slowa danych
  );
end SERIAL_BUS_TB;

architecture behavioural of SERIAL_BUS_TB is

  procedure TB_zegar(T : time; signal C : out std_logic) is
  begin
    loop
      C <= '1';
      wait for T/2;
      C <= '0';
      wait for T/2;
    end loop;
  end procedure;

  procedure TB_reset(T : time; signal R : out std_logic) is
  begin
    R <= '1';
    wait for T;
    R <= '0';
    wait;
  end procedure;

  procedure TB_serial_tx (
    constant L_BODOW		:in  natural;		-- predkosc nadawania w [bodach]
    constant B_PARZYSTOSCI	:in  natural;		-- liczba bitow parzystosci (0-1)
    constant B_STOPOW		:in  natural;		-- liczba bitow stopu (1-2)
    constant N_TX		:in  boolean;		-- negacja logiczna sygnalu szeregowego
    constant N_SLOWO		:in  boolean;		-- negacja logiczna slowa danych
    constant SLOWO		:in  std_logic_vector;	-- wysylane slowo danych
    signal   TX			:out std_logic		-- wysylany sygnal szeregowy
  ) is
    constant T_BODU		:time := 1sec/L_BODOW;
    variable BUFOR		:std_logic_vector(SLOWO'range);
    function tx_neg(TX : std_logic) return std_logic is
    begin
      if (N_TX=TRUE) then
        return (not(TX));
      end if;
      return (TX);
    end function;
  begin
    BUFOR := SLOWO;
    if (N_SLOWO=TRUE) then
      BUFOR := not(SLOWO);
    end if;
    TX <= tx_neg('1');
    wait for T_BODU;
    for i in 0 to SLOWO'length-1 loop
      TX <= tx_neg(BUFOR(i));
      wait for T_BODU;
    end loop;
    if (B_PARZYSTOSCI = 1) then
      TX <= tx_neg(XOR_REDUCE(SLOWO));
      if (N_SLOWO=TRUE) then
        TX <= tx_neg(XOR_REDUCE(not(SLOWO)));
      end if;
      wait for T_BODU;
    end if;
    TX <= tx_neg('0');
    wait for 0 ns;
    for i in 0 to B_STOPOW-1 loop
      wait for T_BODU;
    end loop;
  end procedure;

  procedure TB_serial_rx (
    constant L_BODOW		:in  natural;		-- predkosc nadawania w [bodach]
    constant B_PARZYSTOSCI	:in  natural;		-- liczba bitow parzystosci (0-1)
    constant B_STOPOW		:in  natural;		-- liczba bitow stopu (1-2)
    constant N_RX		:in  boolean;		-- negacja logiczna sygnalu szeregowego
    constant N_SLOWO		:in  boolean;		-- negacja logiczna slowa danych
    signal   RX			:in  std_logic;		-- odbierany sygnal szeregowy
    variable SLOWO		:out std_logic_vector;	-- odbrane slowo danych
    variable BLAD		:out boolean		-- blad odbioru
  ) is
    constant T_BODU		:time := 1sec/L_BODOW;
    variable BUFOR		:std_logic_vector(SLOWO'range);
    variable PROBLEM		:boolean;
    function rx_neg(RX : std_logic) return std_logic is
    begin
      if (N_RX=TRUE) then
        return (not(RX));
      end if;
      return (RX);
    end function;
  begin
    SLOWO    := (others => 'U');
    BUFOR    := (others => '0');
    PROBLEM  := FALSE;
    wait until rx_neg(RX)='1';
    wait for T_BODU/2;
    if (rx_neg(RX) /= '1') then
      PROBLEM := TRUE;
    end if;
    wait for T_BODU;
    for i in 0 to SLOWO'length-1 loop
      BUFOR(i) := rx_neg(RX);
      wait for T_BODU;
    end loop;
    if (B_PARZYSTOSCI = 1) then
      if (rx_neg(RX) /= XOR_REDUCE(BUFOR)) then
        PROBLEM := TRUE;
      end if;
      wait for T_BODU;
    end if;
    for i in 0 to B_STOPOW-1 loop
      if (rx_neg(RX) /= '0') then
        PROBLEM := TRUE;
      end if;
    end loop;
    if (PROBLEM=TRUE) then
      BLAD  := PROBLEM;
      SLOWO := (others => 'X');
    elsif (N_SLOWO = TRUE) then
      SLOWO := not(BUFOR);
    else
      SLOWO := BUFOR;
    end if;
  end procedure;

  procedure TB_serial_synch (
    constant L_BODOW		:in  natural;		-- predkosc nadawania w [bodach]
    constant B_SLOWA		:in  natural;		-- liczba bitow slowa danych (5-8)
    constant B_PARZYSTOSCI	:in  natural;		-- liczba bitow parzystosci (0-1)
    constant B_STOPOW		:in  natural;		-- liczba bitow stopu (1-2)
    constant L_TESTOW		:in  natural;		-- liczba wyslanych slow testowych
    constant N_SERIAL		:in  boolean;		-- negacja logiczna sygnalu szeregowego
    constant N_SLOWO		:in  boolean;		-- negacja logiczna slowa danych
    signal   TX			:out std_logic;		-- wysylany sygnal szeregowy
    signal   RX			:in  std_logic;		-- odbierany sygnal szeregowy
    variable SYNCH		:out boolean		-- wykonano synchronizacje
  ) is
    constant O_BITU		:time := 1sec/L_BODOW;
    variable TX_SLOWO		:std_logic_vector(B_SLOWA-1 downto 0);
    variable RX_SLOWO		:std_logic_vector(B_SLOWA-1 downto 0);
    variable SLOWO_SYNCH	:std_logic_vector(B_SLOWA-1 downto 0);
    constant SLOWO_ZERO		:std_logic_vector(B_SLOWA-1 downto 0) := (others => '0');
    variable BLAD		:boolean;
  begin
    SYNCH := FALSE;
    if (N_SERIAL=FALSE) then TX <= '1'; else TX <= '0'; end if;
    wait for O_BITU;
    if (N_SERIAL=FALSE) then TX <= '0'; else TX <= '1'; end if;
    wait for 0ns;
    -- oebranie slowa synchronizujacego
    TB_serial_rx(L_BODOW, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, RX, RX_SLOWO, BLAD);
    SLOWO_SYNCH := SLOWO_ZERO + X"9A";
    SLOWO_SYNCH(B_SLOWA-1) := '1';
    if (BLAD=TRUE OR RX_SLOWO/=SLOWO_SYNCH) then return; end if;
    -- wyslanie i odebranie sekwencji tetujacej
    TX_SLOWO := SLOWO_ZERO;
    for i in 1 to L_TESTOW loop
      TX_SLOWO := TX_SLOWO + 13;
      if (TX_SLOWO=0) then TX_SLOWO := TX_SLOWO+1; end if;
      TB_serial_tx(L_BODOW, B_PARZYSTOSCI, 0, N_SERIAL, N_SLOWO, TX_SLOWO, TX);
      TB_serial_rx(L_BODOW, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, RX, RX_SLOWO, BLAD);
      if (BLAD=TRUE OR not(RX_SLOWO)/=TX_SLOWO) then return; end if;
    end loop;
    -- wyslanie i odebranie slowa akceptacji synchronizacji
    TX_SLOWO := SLOWO_ZERO;
    TB_serial_tx(L_BODOW, B_PARZYSTOSCI, 0, N_SERIAL, N_SLOWO, TX_SLOWO, TX);
    TB_serial_rx(L_BODOW, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, RX, RX_SLOWO, BLAD);
    if (BLAD=TRUE OR RX_SLOWO /= SLOWO_ZERO) then return; end if;
    SYNCH := TRUE;
  end procedure;
 
  type       TB_serial_bus_konfig is			-- konfiguracja interfejsu
    record
      L_ADRESOW			:natural;		-- liczba slow przypadajacych na adres
      L_DANYCH			:natural;		-- liczba slow przypadajacych na dana
      L_BODOW			:natural;		-- predkosc nadawania w [bodach]
      B_SLOWA			:natural;		-- liczba bitow slowa danych (5-8)
      B_PARZYSTOSCI		:natural;		-- liczba bitow parzystosci (0-1)
      B_STOPOW			:natural;		-- liczba bitow stopu (1-2)
      N_SERIAL			:boolean;		-- negacja logiczna sygnalu szeregowego
      N_SLOWO			:boolean;		-- negacja logiczna slowa danych
    end record;

  procedure TB_serial_bus_inicjal(
    constant L_ADRESOW		:in  natural;		-- liczba slow przypadajacych na adres
    constant L_DANYCH		:in  natural;		-- liczba slow przypadajacych na dana
    constant L_BODOW		:in  natural;		-- predkosc nadawania w [bodach]
    constant B_SLOWA		:in  natural;		-- liczba bitow slowa danych (5-8)
    constant B_PARZYSTOSCI	:in  natural;		-- liczba bitow parzystosci (0-1)
    constant B_STOPOW		:in  natural;		-- liczba bitow stopu (1-2)
    constant N_SERIAL		:in  boolean;		-- negacja logiczna sygnalu szeregowego
    constant N_SLOWO		:in  boolean;		-- negacja logiczna slowa danych
    variable KONFIG		:out TB_serial_bus_konfig; -- konfiguracja interfejsu
    signal   TX			:out std_logic;		-- wysylany sygnal szeregowy
    variable BLAD		:out boolean		-- wykryto blad synchronizacji
  ) is
  begin
    BLAD := TRUE;
    if (L_ADRESOW < 1)            then return; end if;
    if (L_DANYCH < 1)             then return; end if;
    if (L_BODOW <1)               then return; end if;
    if (B_SLOWA<5 or B_SLOWA>8)   then return; end if;
    if (B_PARZYSTOSCI > 1)        then return; end if;
    if (B_STOPOW<1 or B_STOPOW>2) then return; end if;
    TX <= '0';
    if (N_SERIAL=TRUE) then TX <= '1'; end if;
    wait for 0ns;
    KONFIG.L_ADRESOW     := L_ADRESOW;
    KONFIG.L_DANYCH      := L_DANYCH;	
    KONFIG.L_BODOW       := L_BODOW;	
    KONFIG.B_SLOWA       := B_SLOWA;	
    KONFIG.B_PARZYSTOSCI := B_PARZYSTOSCI;
    KONFIG.B_STOPOW      := B_STOPOW;	
    KONFIG.N_SERIAL      := N_SERIAL;	
    KONFIG.N_SLOWO       := N_SLOWO;	
    BLAD := FALSE;
  end procedure;

  procedure TB_serial_bus_synch(
    constant L_TESTOW		:in  natural;		-- liczba wyslanych slow testowych
    constant KONFIG		:in  TB_serial_bus_konfig; -- konfiguracja interfejsu
    signal   TX			:out std_logic;		-- wysylany sygnal szeregowy
    signal   RX			:in  std_logic;		-- odbierany sygnal szeregowy
    variable BLAD		:out boolean		-- wykryto blad synchronizacji
  ) is
    variable SYNC		:boolean;		-- potwierdzenie synchronizacji
  begin
    TB_serial_synch(KONFIG.L_BODOW, KONFIG.B_SLOWA, KONFIG.B_PARZYSTOSCI, KONFIG.B_STOPOW, L_TESTOW, KONFIG.N_SERIAL, KONFIG.N_SLOWO, TX, RX, SYNC);
    BLAD := not(SYNC);
  end procedure;

  procedure TB_serial_bus_zapis(
    constant KONFIG		:in  TB_serial_bus_konfig; -- konfiguracja interfejsu
    constant ADRES		:in  std_logic_vector;	-- magistrala adresowa
    constant DANA		:in  std_logic_vector;	-- wyjsciowa magistrala danych
    signal   TX			:out std_logic;		-- wysylany sygnal szeregowy
    signal   RX			:in  std_logic;		-- odbierany sygnal szeregowy
    variable BLAD		:out boolean		-- wykryto blad odbioru
  ) is
    variable PROBLEM :boolean;
    variable TEST    :std_logic_vector(KONFIG.B_SLOWA-1 downto 0);
    variable SLOWO   :std_logic_vector(KONFIG.B_SLOWA-1 downto 0);
  begin
    BLAD := TRUE;
    TEST := (others => '0');
    for i in 0 to KONFIG.L_ADRESOW-1 loop
      SLOWO := ADRES((i+1)*KONFIG.B_SLOWA-1 downto i*KONFIG.B_SLOWA);
      if (i = KONFIG.L_ADRESOW-1) then SLOWO(SLOWO'length-1) := '1'; end if;
      TB_serial_tx(KONFIG.L_BODOW, KONFIG.B_PARZYSTOSCI, 0, KONFIG.N_SERIAL, KONFIG.N_SLOWO, SLOWO, TX);
      TEST := test_slow(TEST,SLOWO);
      TB_serial_rx(KONFIG.L_BODOW, KONFIG.B_PARZYSTOSCI, KONFIG.B_STOPOW, KONFIG.N_SERIAL, KONFIG.N_SLOWO, RX, SLOWO, PROBLEM);
      if (PROBLEM=TRUE OR SLOWO/=TEST) then return; end if;
    end loop;
    for i in 0 to KONFIG.L_DANYCH-1 loop
      SLOWO := DANA((i+1)*KONFIG.B_SLOWA-1 downto i*KONFIG.B_SLOWA);
      TB_serial_tx(KONFIG.L_BODOW, KONFIG.B_PARZYSTOSCI, 0, KONFIG.N_SERIAL, KONFIG.N_SLOWO, SLOWO, TX);
      TEST := test_slow(TEST,SLOWO);
      TB_serial_rx(KONFIG.L_BODOW, KONFIG.B_PARZYSTOSCI, KONFIG.B_STOPOW, KONFIG.N_SERIAL,KONFIG.N_SLOWO, RX, SLOWO, PROBLEM);
      if (PROBLEM=TRUE OR SLOWO/=TEST) then return; end if;
    end loop;
    TB_serial_tx(KONFIG.L_BODOW, KONFIG.B_PARZYSTOSCI, 0, KONFIG.N_SERIAL, KONFIG.N_SLOWO, TEST, TX);
    TEST := test_slow(TEST,TEST);
    TB_serial_rx(KONFIG.L_BODOW, KONFIG.B_PARZYSTOSCI, KONFIG.B_STOPOW, KONFIG.N_SERIAL,KONFIG.N_SLOWO, RX, SLOWO, PROBLEM);
    if (PROBLEM=TRUE OR SLOWO/=TEST) then return; end if;
    BLAD := FALSE;
  end procedure;

  procedure TB_serial_bus_odczyt(
    constant KONFIG		:in  TB_serial_bus_konfig; -- konfiguracja interfejsu
    constant ADRES		:in  std_logic_vector;	-- magistrala adresowa
    variable DANA		:out std_logic_vector;	-- wyjsciowa magistrala danych
    signal   TX			:out std_logic;		-- wysylany sygnal szeregowy
    signal   RX			:in  std_logic;		-- odbierany sygnal szeregowy
    variable BLAD		:out boolean		-- wykryto blad synchronizacji
  ) is
    variable PROBLEM :boolean;
    variable TEST    :std_logic_vector(KONFIG.B_SLOWA-1 downto 0);
    variable SLOWO   :std_logic_vector(KONFIG.B_SLOWA-1 downto 0);
  begin
    BLAD := TRUE;
    TEST := (others => '0');
    for i in 0 to KONFIG.L_ADRESOW-1 loop
      SLOWO := ADRES((i+1)*KONFIG.B_SLOWA-1 downto i*KONFIG.B_SLOWA);
      if (i = KONFIG.L_ADRESOW-1) then SLOWO(SLOWO'length-1) := '0'; end if;
      TB_serial_tx(KONFIG.L_BODOW, KONFIG.B_PARZYSTOSCI, 0, KONFIG.N_SERIAL, KONFIG.N_SLOWO, SLOWO, TX);
      TEST := test_slow(TEST,SLOWO);
      TB_serial_rx(KONFIG.L_BODOW, KONFIG.B_PARZYSTOSCI, KONFIG.B_STOPOW, KONFIG.N_SERIAL, KONFIG.N_SLOWO, RX, SLOWO, PROBLEM);
      if (PROBLEM=TRUE OR SLOWO/=TEST) then return; end if;
    end loop;
    for i in 0 to KONFIG.L_DANYCH-1 loop
      TB_serial_tx(KONFIG.L_BODOW, KONFIG.B_PARZYSTOSCI, 0, KONFIG.N_SERIAL, KONFIG.N_SLOWO, TEST, TX);
      TB_serial_rx(KONFIG.L_BODOW, KONFIG.B_PARZYSTOSCI, KONFIG.B_STOPOW, KONFIG.N_SERIAL, KONFIG.N_SLOWO, RX, SLOWO, PROBLEM);
      if (PROBLEM=TRUE) then return; end if;
      DANA((i+1)*KONFIG.B_SLOWA-1 downto i*KONFIG.B_SLOWA) := SLOWO;
      TEST := test_slow(TEST,SLOWO);
    end loop;
    TB_serial_tx(KONFIG.L_BODOW, KONFIG.B_PARZYSTOSCI, 0, KONFIG.N_SERIAL, KONFIG.N_SLOWO, TEST, TX);
    TEST := test_slow(TEST,TEST);
    TB_serial_rx(KONFIG.L_BODOW, KONFIG.B_PARZYSTOSCI, KONFIG.B_STOPOW, KONFIG.N_SERIAL, KONFIG.N_SLOWO, RX, SLOWO, PROBLEM);
    if (PROBLEM=TRUE OR SLOWO/=TEST) then return; end if;
    BLAD := FALSE;
  end procedure;

  constant L_BODOW	:natural := 2_000_000;			-- predkosc nadawania w [bodach]
  constant L_TESTOW	:natural := 4;				-- liczba wyslanych slow testowych
  signal   R		:std_logic;				-- sygnal resetowania
  signal   C		:std_logic;				-- zegar taktujacy
  signal   RX		:std_logic;				-- odbierany sygnal szeregowy
  signal   TX		:std_logic;				-- wysylany sygnal szeregowy
  signal   ADRES	:std_logic_vector(L_ADRESOW*B_SLOWA-2 downto 0); -- magistrala adresowa
  signal   DANA_WYJ	:std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0); -- wyjsciowa magistrala danych
  signal   DANA_WEJ	:std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0); -- wejsciowa magistrala danych
  signal   DOSTEP	:std_logic;				-- flaga dostepu do magistrali
  signal   ZAPIS	:std_logic;				-- flaga zapisu (gdy '1') lub odczytu (gdy '0')
  signal   STROB	:std_logic;				-- flaga strobu zegara
  signal   SYNCH_GOTOWA	:std_logic;				-- sygnal potwierdzenia synchronizacji
  signal   BLAD_ODBIORU	:std_logic;				-- sygnal bledu odbioru
  signal   DANA_RD	:std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0); -- wejsciowa magistrala danych
  
  constant O_ZEGARA	:time := 1 sec/F_ZEGARA;
  constant O_BITU	:time := 1 sec/L_BODOW;

  type     WEKTOR	is array(natural range <>) of INTEGER;
  signal   ODBIERANE	:WEKTOR(2*(L_ADRESOW+L_DANYCH+1)+L_TESTOW+1 downto 0);

begin

  TB_zegar(O_ZEGARA,C);
  TB_reset(100ns,R);
  
  process is
    variable ADRES      :std_logic_vector(L_ADRESOW*B_SLOWA-1 downto 0);
    variable DANA       :std_logic_vector(L_DANYCH*B_SLOWA-1 downto 0);
    variable SLOWO 	:std_logic_vector(B_SLOWA-1 downto 0);
    variable KONFIG	:TB_serial_bus_konfig;
    variable BLAD	:boolean;
    
  begin

    TB_serial_bus_inicjal(L_ADRESOW, L_DANYCH, L_BODOW, B_SLOWA, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, KONFIG, RX, BLAD);
    if (BLAD=TRUE) then wait; end if;

    wait until R='0';
    wait for 100ns;

    TB_serial_bus_synch(L_TESTOW, KONFIG, RX, TX, BLAD);
    if (BLAD=TRUE) then wait; end if;

    ADRES := (ADRES'range=>'0')+16#1F10#;
    DANA  := (DANA'range=>'0')+16#44332211#;
    TB_serial_bus_zapis(KONFIG, ADRES, DANA, RX, TX, BLAD);
    if (BLAD=TRUE) then wait; end if;

    ADRES := (ADRES'range=>'0')+16#1F10#;
    DANA  := (others => 'X');
    TB_serial_bus_odczyt(KONFIG, ADRES, DANA, RX, TX, BLAD);
    if (BLAD=TRUE) then wait; end if;
    if (DANA /= DANA_WEJ) then BLAD := TRUE; wait; end if;
    DANA_RD <= DANA;

    wait;
  end process;
  
  DANA_WEJ <= (DANA_WEJ'range=>'0')+16#12345678#;
  serial_bus_inst: entity work.SERIAL_BUS(behavioural)
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
      ADRES           => ADRES,
      DANA_WYJ        => DANA_WYJ,
      DANA_WEJ        => DANA_WEJ,
      DOSTEP          => DOSTEP,
      ZAPIS           => ZAPIS,
      STROB           => STROB,
      SYNCH_GOTOWA    => SYNCH_GOTOWA,
      BLAD_ODBIORU    => BLAD_ODBIORU
   );

  process is
    variable BLAD  :boolean;
    variable SLOWO :std_logic_vector(B_SLOWA-1 downto 0);
  begin
    SLOWO     := (others => '0');
    ODBIERANE <= (others => 0);
    loop
      TB_serial_rx(L_BODOW, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, TX, SLOWO, BLAD);
      ODBIERANE(ODBIERANE'left downto 1) <= ODBIERANE(ODBIERANE'left-1 downto 0);
      ODBIERANE(0) <= CONV_INTEGER(SLOWO);
      if (BLAD=TRUE) then ODBIERANE(0) <= -1; end if;
    end loop;
  end process;
  
end behavioural;

