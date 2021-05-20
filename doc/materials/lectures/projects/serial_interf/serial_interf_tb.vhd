library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_misc.all;

entity SERIAL_INTERF_TB is
  generic (
    F_ZEGARA		:natural := 20_000_000;			-- czestotliwosc zegata w [Hz]
    L_MIN_BODOW		:natural := 110;			-- minimalna predkosc transmisji w [bodach]
    B_SLOWA		:natural := 8;				-- liczba bitow slowa danych (5-8)
    B_PARZYSTOSCI	:natural := 0;				-- liczba bitow parzystosci (0-1)
    B_STOPOW		:natural := 2;				-- liczba bitow stopu (1-2)
    N_SERIAL		:boolean := FALSE;			-- negacja logiczna sygnalu szeregowego
    N_SLOWO		:boolean := FALSE			-- negacja logiczna slowa danych
  );
end SERIAL_INTERF_TB;

architecture behavioural of SERIAL_INTERF_TB is

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

  constant L_BODOW	:natural := 2_000_000;			-- predkosc nadawania w [bodach]
  constant L_TESTOW	:natural := 8;				-- liczba wyslanych slow testowych

  signal   R		:std_logic;				-- sygnal resetowania
  signal   C		:std_logic;				-- zegar taktujacy
  signal   RX		:std_logic;				-- odbierany sygnal szeregowy
  signal   TX		:std_logic;				-- wysylany sygnal szeregowy
  signal   RX_ODEBRANE	:std_logic;				-- flaga potwierdzenia odbioru
  signal   RX_SLOWO	:std_logic_vector(B_SLOWA-1 downto 0);	-- odebrane slowo danych
  signal   TX_WOLNY	:std_logic;				-- flaga gotowosci do nadawania
  signal   TX_NADAJ	:std_logic;				-- flaga zadania nadania
  signal   TX_SLOWO	:std_logic_vector(B_SLOWA-1 downto 0);	-- wysylane slowo danych
  signal   SYNCH_GOTOWA	:std_logic;				-- wysylany sygnal gotowosci
  signal   BLAD_ODBIORU	:std_logic;				-- wysylany sygnal bledu odbioru
  
  constant O_ZEGARA	:time := 1 sec/F_ZEGARA;
  constant O_BITU	:time := 1 sec/L_BODOW;

  type     WEKTOR	is array(natural range <>) of INTEGER;
  constant WYSYLANE	:WEKTOR := (10,20,30,0,100,150,200);
  signal   ODBIERANE	:WEKTOR(WYSYLANE'length+L_TESTOW+1 downto 0);

begin

  TB_zegar(O_ZEGARA,C);
  TB_reset(100ns,R);
  
  process is
    variable SLOWO 	:std_logic_vector(B_SLOWA-1 downto 0);
    variable SYNCH	:boolean;
    variable BLAD	:boolean;
  begin
    if (N_SERIAL=FALSE) then RX <= '0'; else RX <= '1'; end if;
    wait until R='0';
    wait for 100ns;
    TB_serial_synch(L_BODOW, B_SLOWA, B_PARZYSTOSCI, B_STOPOW, L_TESTOW, N_SERIAL, N_SLOWO, RX, TX, SYNCH);
    if (SYNCH=TRUE) then
      for i in 0 to WYSYLANE'length-1 loop
        SLOWO := CONV_STD_LOGIC_VECTOR(WYSYLANE(i),SLOWO'length);
        TB_serial_tx(L_BODOW, B_PARZYSTOSCI, 0, N_SERIAL, N_SLOWO, SLOWO, RX);
        TB_serial_rx(L_BODOW, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, TX, SLOWO, BLAD);
        if (BLAD=TRUE OR SLOWO/=CONV_STD_LOGIC_VECTOR(WYSYLANE(i)+1,SLOWO'length)) then
	  exit;
	end if;
      end loop;
    end if;
    wait;
  end process;
  
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
      R               => R,
      C               => C,
      RX              => RX,
      TX              => TX,
      RX_ODEBRANE     => RX_ODEBRANE,
      RX_SLOWO        => RX_SLOWO,
      TX_WOLNY        => TX_WOLNY,
      TX_NADAJ        => TX_NADAJ,
      TX_SLOWO        => TX_SLOWO,
      SYNCH_GOTOWA    => SYNCH_GOTOWA,
      BLAD_ODBIORU    => BLAD_ODBIORU
   );
   TX_NADAJ <= RX_ODEBRANE;
   TX_SLOWO <= RX_SLOWO+1;

  process is
    variable SLOWO :std_logic_vector(B_SLOWA-1 downto 0);
    variable BLAD	:boolean;
  begin
    SLOWO     := (others => '0');
    ODBIERANE <= (others => 0);
    loop
      TB_serial_rx(L_BODOW, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, TX, SLOWO, BLAD);
      ODBIERANE(ODBIERANE'left-1 downto 1) <= ODBIERANE(ODBIERANE'left-2 downto 0);
      ODBIERANE(0) <= CONV_INTEGER(SLOWO);
      if (BLAD=TRUE) then ODBIERANE(0) <= -1; end if;
    end loop;
  end process;
  

end behavioural;

