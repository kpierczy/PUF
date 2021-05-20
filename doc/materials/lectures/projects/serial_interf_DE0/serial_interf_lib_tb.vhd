library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;

package SERIAL_INTERFACE_LIB_TB is				-- czesc publiczna pakietu 'SERIAL_INTERFACE_LIB_TB'

  procedure TB_zegar(T : time; signal C : out std_logic);	-- naglowek funkcji generacjisygnalu zegara
  procedure TB_reset(T : time; signal R : out std_logic);	-- naglowek funcji  generacji sygnalu resetu

  procedure TB_serial_tx (					-- naglowek funcji emulacji nadajnika RS
    constant L_BODOW		:in  natural;			-- predkosc nadawania w [bodach]
    constant B_PARZYSTOSCI	:in  natural;			-- liczba bitow parzystosci (0-1)
    constant B_STOPOW		:in  natural;			-- liczba bitow stopu (1-2)
    constant N_TX		:in  boolean;			-- negacja logiczna sygnalu szeregowego
    constant N_SLOWO		:in  boolean;			-- negacja logiczna slowa danych
    constant SLOWO		:in  std_logic_vector;		-- wysylane slowo danych
    signal   TX			:out std_logic			-- wysylany sygnal szeregowy
  );

  procedure TB_serial_rx (					-- naglowek funcji emulacji odbiornika RS
    constant L_BODOW		:in  natural;			-- predkosc nadawania w [bodach]
    constant B_PARZYSTOSCI	:in  natural;			-- liczba bitow parzystosci (0-1)
    constant B_STOPOW		:in  natural;			-- liczba bitow stopu (1-2)
    constant N_RX		:in  boolean;			-- negacja logiczna sygnalu szeregowego
    constant N_SLOWO		:in  boolean;			-- negacja logiczna slowa danych
    signal   RX			:in  std_logic;			-- odbierany sygnal szeregowy
    variable SLOWO		:out std_logic_vector;		-- odbrane slowo danych
    variable BLAD		:out boolean			-- blad odbioru
  );

  procedure TB_serial_synch (					-- naglowek funcji emulacji synchronizacji RS
    constant L_BODOW		:in  natural;			-- predkosc nadawania w [bodach]
    constant B_SLOWA		:in  natural;			-- liczba bitow slowa danych (5-8)
    constant B_PARZYSTOSCI	:in  natural;			-- liczba bitow parzystosci (0-1)
    constant B_STOPOW		:in  natural;			-- liczba bitow stopu (1-2)
    constant L_TESTOW		:in  natural;			-- liczba wyslanych slow testowych
    constant N_SERIAL		:in  boolean;			-- negacja logiczna sygnalu szeregowego
    constant N_SLOWO		:in  boolean;			-- negacja logiczna slowa danych
    signal   TX			:out std_logic;			-- wysylany sygnal szeregowy
    signal   RX			:in  std_logic;			-- odbierany sygnal szeregowy
    variable SYNCH		:out boolean			-- wykonano synchronizacje
  );

end package SERIAL_INTERFACE_LIB_TB;				-- zakonczenie czesci publiczna pakietu 'SERIAL_INTERFACE_LIB_TB'

package body SERIAL_INTERFACE_LIB_TB is				-- czesc prywatna pakietu 'SERIAL_INTERFACE_LIB_TB'

  function neg(V :std_logic; N :boolean) return std_logic is	-- definicja funcji prywatnej 'neg'
  begin								-- czesc wykonawcza funcji
    if (N=FALSE) then return (V); end if;			-- zwrocenie 'V' gdy 'N=FALSE'
    return (not(V));						-- zwrocenie negacji 'V'
  end function neg;						-- zakczenie definicji funkcji 'neg'

  procedure TB_zegar(T : time; signal C : out std_logic) is	-- definicja procedury publicznej 'TB_zegar'
  begin								-- czesc wykonawcza procedury
    loop							-- petla nieskonczona
      C <= '0'; wait for T/2;					-- ustawienie 'C' na '0' i odczekanie czasu 'T/2'
      C <= '1'; wait for T/2;					-- ustawienie 'C' na '1' i odczekanie czasu 'T/2'
    end loop;							-- zakonczenie petli
  end procedure TB_zegar;					-- zakczenie definicji procedury 'TB_zegar'

  procedure TB_reset(T : time; signal R : out std_logic) is	-- definicja procedury publicznej 'TB_reset'
  begin								-- czesc wykonawcza procedury
    R <= '0'; wait for T;					-- ustawienie sygnalu 'R' na '0' i odczekanie czasu 'T'
    R <= '1'; wait;						-- ustawienie sygnalu 'R' na '1' i zatrzymanie procedury
  end procedure TB_reset;					-- zakczenie definicji procedury 'TB_reset'

  procedure TB_serial_tx (					-- definicja procedury publicznej 'TB_serial_tx'
    constant L_BODOW		:in  natural;			-- predkosc nadawania w [bodach]
    constant B_PARZYSTOSCI	:in  natural;			-- liczba bitow parzystosci (0-1)
    constant B_STOPOW		:in  natural;			-- liczba bitow stopu (1-2)
    constant N_TX		:in  boolean;			-- negacja logiczna sygnalu szeregowego
    constant N_SLOWO		:in  boolean;			-- negacja logiczna slowa danych
    constant SLOWO		:in  std_logic_vector;		-- wysylane slowo danych
    signal   TX			:out std_logic			-- wysylany sygnal szeregowy
  ) is								-- czesc deklaracyjna procedury
    constant T_BODU		:time := 1 sec/L_BODOW;		-- deklaracja stalej 'T_BODU' o wartosci czasu jednego bodu
  begin								-- czesc wykonawcza procedury
    TX <= neg('1',N_TX);					-- ustawienie sygnalu 'TX' na zmodyfikowana wartosc bitu START
    wait for T_BODU;						-- odczekanie jednego bodu
    for i in 0 to SLOWO'length-1 loop				-- petla po kolejnych bitach nadawanego slowa 'SLOWO'
      TX <= neg(neg(SLOWO(i),N_SLOWO),N_TX);			-- ustawienie sygnalu 'TX' na zmodyfikowana wartosc bitu 'SLOWO(i)'
      wait for T_BODU;						-- odczekanie jednego bodu
    end loop;							-- zakonczenie petli
    if (B_PARZYSTOSCI = 1) then					-- badanie aktywowania bitu parzystosci
      TX <= neg(neg(XOR_REDUCE(SLOWO),N_SLOWO),N_TX);		-- ustawienie sygnalu 'TX' na zmodyfikowana wartosc bitu parzystosci	
      wait for T_BODU;						-- odczekanie jednego bodu
    end if;							-- zakonczenie instukcji warunkowej
    TX <= neg('0',N_TX);					-- ustawienie sygnalu 'TX' na zmodyfikowana wartosc bitu STOP
    wait for 0 ns;						-- aktualizacji sygnalu 'TX' poprzez pusta instrukcje odczekania
    for i in 0 to B_STOPOW-1 loop				-- petla po liczbie bitow stopu
      wait for T_BODU;						-- odczekanie jednego bodu
    end loop;							-- zakonczenie petli
  end procedure TB_serial_tx;					-- zakczenie definicji procedury 'TB_serial_tx'

  procedure TB_serial_rx (
    constant L_BODOW		:in  natural;			-- predkosc nadawania w [bodach]
    constant B_PARZYSTOSCI	:in  natural;			-- liczba bitow parzystosci (0-1)
    constant B_STOPOW		:in  natural;			-- liczba bitow stopu (1-2)
    constant N_RX		:in  boolean;			-- negacja logiczna sygnalu szeregowego
    constant N_SLOWO		:in  boolean;			-- negacja logiczna slowa danych
    signal   RX			:in  std_logic;			-- odbierany sygnal szeregowy
    variable SLOWO		:out std_logic_vector;		-- odbrane slowo danych
    variable BLAD		:out boolean			-- blad odbioru
  ) is								-- czesc deklaracyjna procedury
    constant T_BODU		:time := 1 sec/L_BODOW;		-- deklaracja stalej 'T_BODU' o wartosci czasu jednego bodu
    variable BUFOR		:std_logic_vector(SLOWO'range);	-- deklaracja zmiennej 'BUFOR' odebrananego slowa
    variable PROBLEM		:boolean;			-- deklaracja zmiennej 'PROBLEM' wskazujacej nieprawidlowy odbior
  begin								-- czesc wykonawcza procedury
    SLOWO    := (SLOWO'range => 'X');				-- inicjalizacja 'SLOWO' na wartosci bitow 'X'
    BUFOR    := (BUFOR'range => '0');				-- inicjalizacja 'BUFOR' na wartosci bitow '0'
    PROBLEM  := FALSE;						-- inicjalizacja 'PROBLEM' na wartosc 'FALSE'
    wait until neg(RX,N_RX)='1';				-- oczekiwanie na RS na bit startu
    wait for T_BODU/2;						-- odczekanie polowy bodu
    if (neg(RX,N_RX) /= '1') then				-- badanie niezgodnosci zmodyfikowanego 'RX' z wartoscia '1'
      PROBLEM := TRUE;						-- ustawienie zmiennej 'PROBLEM' na 'TRUE'
    end if;							-- zakonczenie instukcji warunkowej
    for i in 0 to SLOWO'length-1 loop				-- petla po liczbie bitow slowa danych 'SLOWO'
      wait for T_BODU;						-- odczekanie jednego bodu
      BUFOR(i) := neg(neg(RX,N_RX),N_SLOWO);			-- przypodanie do bitu 'i' slowa 'ODEBRANO' zmodyfikowanego 'RX'
    end loop;							-- zakonczenie petli
    if (B_PARZYSTOSCI = 1) then					-- badanie aktywowania bitu parzystosci
      wait for T_BODU;						-- odczekanie jednego bodu
      if (neg(neg(RX,N_RX),N_SLOWO) /= XOR_REDUCE(BUFOR)) then	-- badanie niezgodnosci oczekwanej wartosci bitu parzystosci
        PROBLEM := TRUE;					-- ustawienie zmiennej 'PROBLEM' na 'TRUE'
      end if;							-- zakonczenie instukcji warunkowej
    end if;							-- zakonczenie instukcji warunkowej
    for i in 0 to B_STOPOW-1 loop				-- petla po liczbie bitow STOP
      wait for T_BODU;						-- odczekanie jednego bodu
      if (neg(RX,N_RX) /= '0') then				-- badanie niezgodnosci zmodyfikowanego 'RX' z wartoscia '0'
        PROBLEM := TRUE;					-- ustawienie zmiennej 'PROBLEM' na 'TRUE'
      end if;							-- zakonczenie instukcji warunkowej
    end loop;							-- zakonczenie petli
    BLAD  := PROBLEM;						-- przypisanie do  'BLAD' wartosci zmiennej 'PROBLEM'
    if (PROBLEM=FALSE) then					-- badanie czy nie zarejestowano bledu w odbiorze
      SLOWO := BUFOR;						-- przypisanie do 'SLOWO' wartosci zmiennej 'BUFOR'
    end if;							-- zakonczenie instukcji warunkowej
  end procedure TB_serial_rx;					-- zakczenie definicji procedury 'TB_serial_rx'

  procedure TB_serial_synch (
    constant L_BODOW		:in  natural;			-- predkosc nadawania w [bodach]
    constant B_SLOWA		:in  natural;			-- liczba bitow slowa danych (5-8)
    constant B_PARZYSTOSCI	:in  natural;			-- liczba bitow parzystosci (0-1)
    constant B_STOPOW		:in  natural;			-- liczba bitow stopu (1-2)
    constant L_TESTOW		:in  natural;			-- liczba wyslanych slow testowych
    constant N_SERIAL		:in  boolean;			-- negacja logiczna sygnalu szeregowego
    constant N_SLOWO		:in  boolean;			-- negacja logiczna slowa danych
    signal   TX			:out std_logic;			-- wysylany sygnal szeregowy
    signal   RX			:in  std_logic;			-- odbierany sygnal szeregowy
    variable SYNCH		:out boolean			-- wykonano synchronizacje
  ) is								-- czesc deklaracyjna procedury
    constant O_BITU		:time := 1 sec/L_BODOW;		-- deklaracja stalej 'T_BODU' o wartosci czasu jednego bodu
    variable TX_SLOWO		:std_logic_vector(B_SLOWA-1 downto 0); -- deklarazja zmiennej 'TX_SLOWO' wartosci nadawanej
    variable RX_SLOWO		:std_logic_vector(B_SLOWA-1 downto 0); -- deklarazja zmiennej 'RX_SLOWO' wartosci odebranej
    variable BLAD		:boolean;			-- deklaracja zmiennej 'BLAD'
  begin								-- czesc wykonawcza procedury
    SYNCH := FALSE;						-- ustawienie 'SYNCH' na wartosc 'FALSE'
    TX <= neg('1',N_SERIAL);					-- ustawienie sygnalu 'TX' na zmodyfikowana wartosc bitu START
    wait for O_BITU;						-- odczekanie jednego bodu
    TX <= neg('0',N_SERIAL);					-- ustawienie sygnalu 'TX' na zmodyfikowana wartosc bitu STOP
    wait for 0 ns;						-- odczekanie jednego bodu
    -- oebranie slowa synchronizujacego
    TB_serial_rx(L_BODOW, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, RX, RX_SLOWO, BLAD); -- wywolanie procedury odbioru slowa
    TX_SLOWO := (TX_SLOWO'range => '0') + X"A9";		-- przypisanie 'TX_SLOWO' wartosci testowej 'A9'
    TX_SLOWO(B_SLOWA-1) := '1';					-- przypisanie wartosci '1' do najstarszego bitu 'TX_SLOWO'
    if (BLAD=TRUE OR RX_SLOWO/=TX_SLOWO) then return; end if;	-- powrot gdy wystapil blad odbioru 'BLAD' lub odbrano zla wartosc
    -- wyslanie i odebranie sekwencji tetujacej
    TX_SLOWO := (others => '0');				-- ustawienie bitow 'TX_SLOWO' na '0'
    for i in 1 to L_TESTOW loop					-- petla po liczbie zadanych testow
      TX_SLOWO := TX_SLOWO + 13;				-- wyznaczenie nowej wysylanej wartosci testowej przed dodanie 13
      if (TX_SLOWO=0) then TX_SLOWO := TX_SLOWO+1; end if;	-- ustawienie wartosci testowej na 1 gdy posiada wartosc 0
      TB_serial_tx(L_BODOW, B_PARZYSTOSCI, 0, N_SERIAL, N_SLOWO, TX_SLOWO, TX); -- wywolanie procedury nadawania slowa (0 bitow STOP!)
      TB_serial_rx(L_BODOW, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, RX, RX_SLOWO, BLAD); -- wywolanie procedury odbioru slowa 
      if (BLAD=TRUE OR not(RX_SLOWO)/=TX_SLOWO) then return; end if; -- powrot gdy odbrano zla wartosc
    end loop;							-- zakonczenie petli
    -- wyslanie i odebranie slowa akceptacji synchronizacji
    TX_SLOWO := (others => '0');				-- ustawienie bitow 'TX_SLOWO' na '0'
    TB_serial_tx(L_BODOW, B_PARZYSTOSCI, 0, N_SERIAL, N_SLOWO, TX_SLOWO, TX); -- wywolanie procedury nadawania slowa (0 bitow STOP!)
    TB_serial_rx(L_BODOW, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, RX, RX_SLOWO, BLAD); -- wywolanie procedury odbioru slowa 
    if (BLAD=TRUE OR RX_SLOWO /= TX_SLOWO) then return; end if;	-- powrot gdy odbrano zla wartosc
    SYNCH := TRUE;						-- ustawienie 'SYNCH' na wartosc 'TRUE'
  end procedure TB_serial_synch;				-- zakczenie definicji procedury 'TB_serial_synch'

end package body SERIAL_INTERFACE_LIB_TB;			-- zakonczenie czesci prywatnej pakietu 'SERIAL_INTERFACE_LIB_TB'
