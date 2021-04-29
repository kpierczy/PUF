library ieee;							-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;				-- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_unsigned.all;				-- dolaczenie calego pakietu 'STD_LOGIC_UNSIGNED'
use     ieee.std_logic_misc.all;				-- dolaczenie calego pakietu 'STD_LOGIC_MISC'

use     work.SERIAL_INTERFACE_LIB_TB.all;			-- dolaczenie calego pakietu 'SERIAL_INTERFACE_LIB_TB'

entity DE0_TEST_RS_TB is					-- pusty sprzeg projektu symulacji 'DE0_TEST_RS_TB'
  generic (
    F_ZEGARA		:natural := 50_000_000;			-- czestotliwosc zegata w [Hz]
    L_MIN_BODOW		:natural := 110;			-- minimalna predkosc transmisji w [bodach]
    B_SLOWA		:natural := 8;				-- liczba bitow slowa danych (5-8)
    B_PARZYSTOSCI	:natural := 0;				-- liczba bitow parzystosci (0-1)
    B_STOPOW		:natural := 1;				-- liczba bitow stopu (1-2)
    N_SERIAL		:boolean := FALSE;			-- negacja logiczna sygnalu szeregowego
    N_SLOWO		:boolean := FALSE			-- negacja logiczna slowa danych
  );
end DE0_TEST_RS_TB;

architecture cialo_tb of DE0_TEST_RS_TB is			-- cialo architektoniczne projektu 'cialo_tb'

  constant L_BODOW	:natural := 5_000_000;			-- predkosc nadawania w [bodach]
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
  
  constant O_ZEGARA	:time := 1 sec/F_ZEGARA;		-- deklaracja stalej 'O_ZEGARA' o wartosci czasu okresu zegara
  constant O_BITU	:time := 1 sec/L_BODOW;			-- deklaracja stalej 'O_BITU' o wartosci czasu jednego bodu

  type     WEKTOR	is array(natural range <>) of INTEGER;	-- typ tablicy transmitowanych slow
  constant WYSYLANE	:WEKTOR := (10,20,30,0,100,150,200);	-- tablica wysylanych slow
  signal   ODBIERANE	:WEKTOR(WYSYLANE'length+L_TESTOW+1 downto 0); -- tablica odebrnych slow

begin								-- czesc wykonawcza ciala architektoniznego

  TB_zegar(O_ZEGARA,C);						-- wywolanie procedury generacji sygnalu zegara 'C'
  TB_reset(100 ns,R);						-- wywolanie procedury generacji sygnalu resetu 'R'
  
  process is							-- proces bezwarunkowy
    variable SLOWO 	:std_logic_vector(B_SLOWA-1 downto 0);	-- deklaracja zmiennej 'SLOWO' transmitowanego slowa
    variable SYNCH	:boolean;				-- deklaracja zmiennej 'SYNCH' stanu synchronizacja
    variable BLAD	:boolean;				-- deklaracja zmiennej 'BLAD' wykrycia bledu odbioru
  begin								-- czesc wykonawcza procesu
    if (N_SERIAL=FALSE) then RX <= '0'; else RX <= '1'; end if;	-- ustawienie sygnalu 'RX' w stanie spoczynkowym (STOP)
    wait until R='1';						-- oczekiwanie na zakoncznie stanu resetowania
    wait for 100 ns;						-- odczekanie 100 ns
    TB_serial_synch(L_BODOW, B_SLOWA, B_PARZYSTOSCI, B_STOPOW, L_TESTOW, N_SERIAL, N_SLOWO, RX, TX, SYNCH); -- wywo?anie synchronizacji
    if (SYNCH=TRUE) then					-- badanie czy osiagnieto stan synchronizacji
      for i in 0 to WYSYLANE'length-1 loop			-- petla 'i' po kolejnych indeksach tablicy wywylanych slow
        SLOWO := (SLOWO'range => '0') + WYSYLANE(i);		-- przypisanie do 'SLOWO' wartosci z tablicy 'WYSYLANE(i)'
        TB_serial_tx(L_BODOW, B_PARZYSTOSCI, 0, N_SERIAL, N_SLOWO, SLOWO, RX);  -- wowolanie procedury nadawania (0 bitow STOP!)
        TB_serial_rx(L_BODOW, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, TX, SLOWO, BLAD); -- wywolanie procedury odbioru
        if (BLAD=TRUE OR SLOWO/=((SLOWO'range => '0')+WYSYLANE(i)+1)) then -- badanie bledu odbioru 'BLAD' i niepoprawnosci danej 'SLOWO'
	  BLAD := TRUE; exit;					-- ustawienie 'BLAD' na 'TRUE' i bezwarunkowe przerwanie wykonywania petli
	end if;							-- zakonczenie instukcji warunkowej
      end loop;							-- zakonczenie petli
    end if;							-- zakonczenie instukcji warunkowej
    assert (BLAD=FALSE)	report "wykryto blad - symulacja zostala przerwana" severity warning; -- generowanie raportu przy wystapieniu bledu
    wait;							-- bezwarunkowe zatrzymanie wykoywania procesu
  end process;							-- zakonczenie procesu
  
  serial_interf_inst: entity work.SERIAL_INTERF(behavioural)	-- instancja 'SERIAL_INTERF(behavioural)' 
    generic map (						-- mapowanie parametrow biezacych
      F_ZEGARA		=> F_ZEGARA,				-- czestotliwosc zegata w [Hz]
      L_MIN_BODOW	=> L_MIN_BODOW,				-- minimalna predkosc nadawania w [bodach]
      B_SLOWA		=> B_SLOWA,				-- liczba bitow slowa danych (5-8)
      B_PARZYSTOSCI	=> B_PARZYSTOSCI,			-- liczba bitow parzystosci (0-1)
      B_STOPOW		=> B_STOPOW,				-- liczba bitow stopu (1-2)
      N_SERIAL		=> N_SERIAL,				-- negacja logiczna sygnalu szeregowego
      N_SLOWO		=> N_SLOWO				-- negacja logiczna slowa danych
    )
    port map (							-- mapowanie sygnalow do portow
      R			=> R,					-- sygnal resetowania
      C			=> C,					-- zegar taktujacy
      RX		=> RX,					-- odbierany sygnal szeregowy
      TX		=> TX,					-- wysylany sygnal szeregowy
      RX_ODEBRANE	=> RX_ODEBRANE,				-- flaga potwierdzenia odbioru
      RX_SLOWO		=> RX_SLOWO,				-- odebrane slowo danych
      TX_WOLNY		=> TX_WOLNY,				-- flaga gotowosci do nadawania
      TX_NADAJ		=> TX_NADAJ,				-- flaga zadania nadania
      TX_SLOWO		=> TX_SLOWO,				-- wysylane slowo danych
      SYNCH_GOTOWA	=> SYNCH_GOTOWA,			-- wysylany sygnal gotowosci
      BLAD_ODBIORU	=> BLAD_ODBIORU				-- wysylany sygnal bledu odbioru
   );
   TX_NADAJ <= RX_ODEBRANE;					-- przypisanie do 'TX_NADAJ' wartosci 'RX_ODEBRANE'
   TX_SLOWO <= RX_SLOWO+1;					-- przypisanie do 'TX_SLOWO' wartosci 'RX_SLOWO+1'

  process is							-- proces bezwarunkowy
    variable SLOWO :std_logic_vector(B_SLOWA-1 downto 0);	-- deklaracja zmiennej 'SLOWO' odebranego slowa
    variable BLAD  :boolean;					-- deklaracja zmiennej 'BLAD' wykrycia bledu odbioru
  begin								-- czesc wykonawcza procesu
    SLOWO     := (others => '0');				-- ustawienie bitow 'SLOWO' na '0'
    ODBIERANE <= (others => 0);					-- ustawienie elementow tablicy 'ODBIERANE' na '0'
    loop							-- petla nieskonczona
      TB_serial_rx(L_BODOW, B_PARZYSTOSCI, B_STOPOW, N_SERIAL, N_SLOWO, TX, SLOWO, BLAD); -- wywolanie procedury odbioru
      ODBIERANE(ODBIERANE'left downto 1) <= ODBIERANE(ODBIERANE'left-1 downto 0); -- przesuniecie elementow 'ODBIERANE' w lewo
      ODBIERANE(0) <= CONV_INTEGER(SLOWO);			-- przypisanie do 'ODBIERANE(0)' watosci 'SLOWO'
      if (BLAD=TRUE) then ODBIERANE(0) <= -1; end if;		-- gdy wystapil blad to przypisanie do 'ODBIERANE(0)' watosci '-1'
    end loop;							-- zakonczenie petli
  end process;							-- zakonczenie procesu

end cialo_tb;			        			-- zakonczenie ciala architektonicznego 'cialo_tb'
